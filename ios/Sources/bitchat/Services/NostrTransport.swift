import BitLogger
import Foundation
import Combine

// Minimal Nostr transport conforming to Transport for offline sending
final class NostrTransport: Transport {
    // Provide BLE short peer ID for BitChat embedding
    var senderPeerID = PeerID(str: "")

    // Throttle READ receipts to avoid relay rate limits
    private struct QueuedRead {
        let receipt: ReadReceipt
        let peerID: PeerID
    }
    private var readQueue: [QueuedRead] = []
    private var isSendingReadAcks = false
    private let readAckInterval: TimeInterval = TransportConfig.nostrReadAckInterval
    private let keychain: KeychainManagerProtocol

    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }

    // MARK: - Transport Protocol Conformance

    weak var delegate: BitchatDelegate?
    weak var peerEventsDelegate: TransportPeerEventsDelegate?

    var peerSnapshotPublisher: AnyPublisher<[TransportPeerSnapshot], Never> {
        Just([]).eraseToAnyPublisher()
    }
    func currentPeerSnapshots() -> [TransportPeerSnapshot] { [] }

    var myPeerID: PeerID { senderPeerID }
    var myNickname: String { "" }
    func setNickname(_ nickname: String) { /* not used for Nostr */ }

    func startServices() { /* no-op */ }
    func stopServices() { /* no-op */ }
    func emergencyDisconnectAll() { /* no-op */ }

    func isPeerConnected(_ peerID: PeerID) -> Bool { false }
    func isPeerReachable(_ peerID: PeerID) -> Bool { false }
    func peerNickname(peerID: PeerID) -> String? { nil }
    func getPeerNicknames() -> [PeerID : String] { [:] }

    func getFingerprint(for peerID: PeerID) -> String? { nil }
    func getNoiseSessionState(for peerID: PeerID) -> LazyHandshakeState { .none }
    func triggerHandshake(with peerID: PeerID) { /* no-op */ }
    
    // Nostr does not use Noise sessions here; return a cached placeholder to avoid reallocation
    private static var cachedNoiseService: NoiseEncryptionService?
    func getNoiseService() -> NoiseEncryptionService {
        if let noiseService = Self.cachedNoiseService {
            return noiseService
        }
        let noiseService = NoiseEncryptionService(keychain: keychain)
        Self.cachedNoiseService = noiseService
        return noiseService
    }

    // Public broadcast not supported over Nostr here
    func sendMessage(_ content: String, mentions: [String]) { /* no-op */ }

    func sendPrivateMessage(_ content: String, to peerID: PeerID, recipientNickname: String, messageID: String) {
        Task { @MainActor in
            guard let recipientNpub = resolveRecipientNpub(for: peerID) else { return }
            guard let senderIdentity = try? NostrIdentityBridge.getCurrentNostrIdentity() else { return }
            SecureLogger.debug("NostrTransport: preparing PM to \(recipientNpub.prefix(16))… for peerID \(peerID.id.prefix(8))… id=\(messageID.prefix(8))…", category: .session)
            // Convert recipient npub -> hex (x-only)
            let recipientHex: String
            do {
                let (hrp, data) = try Bech32.decode(recipientNpub)
                guard hrp == "npub" else {
                    SecureLogger.error("NostrTransport: recipient key not npub (hrp=\(hrp))", category: .session)
                    return
                }
                recipientHex = data.hexEncodedString()
            } catch {
                SecureLogger.error("NostrTransport: failed to decode npub -> hex: \(error)", category: .session)
                return
            }
            guard let embedded = NostrEmbeddedBitChat.encodePMForNostr(content: content, messageID: messageID, recipientPeerID: peerID.id, senderPeerID: senderPeerID.id) else {
                SecureLogger.error("NostrTransport: failed to embed PM packet", category: .session)
                return
            }
            guard let event = try? NostrProtocol.createPrivateMessage(content: embedded, recipientPubkey: recipientHex, senderIdentity: senderIdentity) else {
                SecureLogger.error("NostrTransport: failed to build Nostr event for PM", category: .session)
                return
            }
            SecureLogger.debug("NostrTransport: sending PM giftWrap id=\(event.id.prefix(16))…", category: .session)
            NostrRelayManager.shared.sendEvent(event)
        }
    }

    func sendReadReceipt(_ receipt: ReadReceipt, to peerID: PeerID) {
        // Enqueue and process with throttling to avoid relay rate limits
        readQueue.append(QueuedRead(receipt: receipt, peerID: peerID))
        processReadQueueIfNeeded()
    }

    func sendFavoriteNotification(to peerID: PeerID, isFavorite: Bool) {
        Task { @MainActor in
            guard let recipientNpub = resolveRecipientNpub(for: peerID) else { return }
            guard let senderIdentity = try? NostrIdentityBridge.getCurrentNostrIdentity() else { return }
            let content = isFavorite ? "[FAVORITED]:\(senderIdentity.npub)" : "[UNFAVORITED]:\(senderIdentity.npub)"
            SecureLogger.debug("NostrTransport: preparing FAVORITE(\(isFavorite)) to \(recipientNpub.prefix(16))…", category: .session)
            // Convert recipient npub -> hex
            let recipientHex: String
            do {
                let (hrp, data) = try Bech32.decode(recipientNpub)
                guard hrp == "npub" else { return }
                recipientHex = data.hexEncodedString()
            } catch { return }
            guard let embedded = NostrEmbeddedBitChat.encodePMForNostr(content: content, messageID: UUID().uuidString, recipientPeerID: peerID.id, senderPeerID: senderPeerID.id) else {
                SecureLogger.error("NostrTransport: failed to embed favorite notification", category: .session)
                return
            }
            guard let event = try? NostrProtocol.createPrivateMessage(content: embedded, recipientPubkey: recipientHex, senderIdentity: senderIdentity) else {
                SecureLogger.error("NostrTransport: failed to build Nostr event for favorite notification", category: .session)
                return
            }
            SecureLogger.debug("NostrTransport: sending favorite giftWrap id=\(event.id.prefix(16))…", category: .session)
            NostrRelayManager.shared.sendEvent(event)
        }
    }

    func sendBroadcastAnnounce() { /* no-op for Nostr */ }
    func sendDeliveryAck(for messageID: String, to peerID: PeerID) {
        Task { @MainActor in
            guard let recipientNpub = resolveRecipientNpub(for: peerID) else { return }
            guard let senderIdentity = try? NostrIdentityBridge.getCurrentNostrIdentity() else { return }
            SecureLogger.debug("NostrTransport: preparing DELIVERED ack for id=\(messageID.prefix(8))… to \(recipientNpub.prefix(16))…", category: .session)
            let recipientHex: String
            do {
                let (hrp, data) = try Bech32.decode(recipientNpub)
                guard hrp == "npub" else { return }
                recipientHex = data.hexEncodedString()
            } catch { return }
            guard let ack = NostrEmbeddedBitChat.encodeAckForNostr(type: .delivered, messageID: messageID, recipientPeerID: peerID.id, senderPeerID: senderPeerID.id) else {
                SecureLogger.error("NostrTransport: failed to embed DELIVERED ack", category: .session)
                return
            }
            guard let event = try? NostrProtocol.createPrivateMessage(content: ack, recipientPubkey: recipientHex, senderIdentity: senderIdentity) else {
                SecureLogger.error("NostrTransport: failed to build Nostr event for DELIVERED ack", category: .session)
                return
            }
            SecureLogger.debug("NostrTransport: sending DELIVERED ack giftWrap id=\(event.id.prefix(16))…", category: .session)
            NostrRelayManager.shared.sendEvent(event)
        }
    }
}

// MARK: - Geohash Helpers

extension NostrTransport {

    // MARK: Geohash ACK helpers
    func sendDeliveryAckGeohash(for messageID: String, toRecipientHex recipientHex: String, from identity: NostrIdentity) {
        Task { @MainActor in
            SecureLogger.debug("GeoDM: send DELIVERED -> recip=\(recipientHex.prefix(8))… mid=\(messageID.prefix(8))… from=\(identity.publicKeyHex.prefix(8))…", category: .session)
            guard let embedded = NostrEmbeddedBitChat.encodeAckForNostrNoRecipient(type: .delivered, messageID: messageID, senderPeerID: senderPeerID.id) else { return }
            guard let event = try? NostrProtocol.createPrivateMessage(content: embedded, recipientPubkey: recipientHex, senderIdentity: identity) else { return }
            NostrRelayManager.registerPendingGiftWrap(id: event.id)
            NostrRelayManager.shared.sendEvent(event)
        }
    }

    func sendReadReceiptGeohash(_ messageID: String, toRecipientHex recipientHex: String, from identity: NostrIdentity) {
        Task { @MainActor in
            SecureLogger.debug("GeoDM: send READ -> recip=\(recipientHex.prefix(8))… mid=\(messageID.prefix(8))… from=\(identity.publicKeyHex.prefix(8))…", category: .session)
            guard let embedded = NostrEmbeddedBitChat.encodeAckForNostrNoRecipient(type: .readReceipt, messageID: messageID, senderPeerID: senderPeerID.id) else { return }
            guard let event = try? NostrProtocol.createPrivateMessage(content: embedded, recipientPubkey: recipientHex, senderIdentity: identity) else { return }
            NostrRelayManager.registerPendingGiftWrap(id: event.id)
            NostrRelayManager.shared.sendEvent(event)
        }
    }

    // MARK: Geohash DMs (per-geohash identity)
    func sendPrivateMessageGeohash(content: String, toRecipientHex recipientHex: String, from identity: NostrIdentity, messageID: String) {
        Task { @MainActor in
            guard !recipientHex.isEmpty else { return }
            SecureLogger.debug("GeoDM: send PM -> recip=\(recipientHex.prefix(8))… mid=\(messageID.prefix(8))… from=\(identity.publicKeyHex.prefix(8))…", category: .session)
            // Build embedded BitChat packet without recipient peer ID
            guard let embedded = NostrEmbeddedBitChat.encodePMForNostrNoRecipient(content: content, messageID: messageID, senderPeerID: senderPeerID.id) else {
                SecureLogger.error("NostrTransport: failed to embed geohash PM packet", category: .session)
                return
            }
            guard let event = try? NostrProtocol.createPrivateMessage(content: embedded, recipientPubkey: recipientHex, senderIdentity: identity) else {
                SecureLogger.error("NostrTransport: failed to build Nostr event for geohash PM", category: .session)
                return
            }
            SecureLogger.debug("NostrTransport: sending geohash PM giftWrap id=\(event.id.prefix(16))…", category: .session)
            NostrRelayManager.registerPendingGiftWrap(id: event.id)
            NostrRelayManager.shared.sendEvent(event)
        }
    }
}

// MARK: - Private Helpers

extension NostrTransport {
    private func processReadQueueIfNeeded() {
        guard !isSendingReadAcks else { return }
        guard !readQueue.isEmpty else { return }
        isSendingReadAcks = true
        sendNextReadAck()
    }

    private func sendNextReadAck() {
        guard !readQueue.isEmpty else { isSendingReadAcks = false; return }
        let item = readQueue.removeFirst()
        Task { @MainActor in
            guard let recipientNpub = resolveRecipientNpub(for: item.peerID) else { scheduleNextReadAck(); return }
            guard let senderIdentity = try? NostrIdentityBridge.getCurrentNostrIdentity() else { scheduleNextReadAck(); return }
            SecureLogger.debug("NostrTransport: preparing READ ack for id=\(item.receipt.originalMessageID.prefix(8))… to \(recipientNpub.prefix(16))…", category: .session)
            // Convert recipient npub -> hex
            let recipientHex: String
            do {
                let (hrp, data) = try Bech32.decode(recipientNpub)
                guard hrp == "npub" else { scheduleNextReadAck(); return }
                recipientHex = data.hexEncodedString()
            } catch { scheduleNextReadAck(); return }
            guard let ack = NostrEmbeddedBitChat.encodeAckForNostr(type: .readReceipt, messageID: item.receipt.originalMessageID, recipientPeerID: item.peerID.id, senderPeerID: senderPeerID.id) else {
                SecureLogger.error("NostrTransport: failed to embed READ ack", category: .session)
                scheduleNextReadAck(); return
            }
            guard let event = try? NostrProtocol.createPrivateMessage(content: ack, recipientPubkey: recipientHex, senderIdentity: senderIdentity) else {
                SecureLogger.error("NostrTransport: failed to build Nostr event for READ ack", category: .session)
                scheduleNextReadAck(); return
            }
            SecureLogger.debug("NostrTransport: sending READ ack giftWrap id=\(event.id.prefix(16))…", category: .session)
            NostrRelayManager.shared.sendEvent(event)
            scheduleNextReadAck()
        }
    }

    private func scheduleNextReadAck() {
        DispatchQueue.main.asyncAfter(deadline: .now() + readAckInterval) { [weak self] in
            guard let self = self else { return }
            self.isSendingReadAcks = false
            self.processReadQueueIfNeeded()
        }
    }

    @MainActor
    private func resolveRecipientNpub(for peerID: PeerID) -> String? {
        if let noiseKey = Data(hexString: peerID.id),
           let fav = FavoritesPersistenceService.shared.getFavoriteStatus(for: noiseKey),
           let npub = fav.peerNostrPublicKey {
            return npub
        }
        if peerID.id.count == 16,
           let fav = FavoritesPersistenceService.shared.getFavoriteStatus(forPeerID: peerID),
           let npub = fav.peerNostrPublicKey {
            return npub
        }
        return nil
    }
}
