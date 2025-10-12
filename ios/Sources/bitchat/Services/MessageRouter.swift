import BitLogger
import Foundation

/// Routes messages between BLE and Nostr transports
@MainActor
final class MessageRouter {
    private let mesh: Transport
    private let nostr: NostrTransport
    private var outbox: [PeerID: [(content: String, nickname: String, messageID: String)]] = [:] // peerID -> queued messages

    init(mesh: Transport, nostr: NostrTransport) {
        self.mesh = mesh
        self.nostr = nostr
        self.nostr.senderPeerID = mesh.myPeerID

        // Observe favorites changes to learn Nostr mapping and flush queued messages
        NotificationCenter.default.addObserver(
            forName: .favoriteStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self = self else { return }
            if let data = note.userInfo?["peerPublicKey"] as? Data {
                let peerID = PeerID(publicKey: data)
                Task { @MainActor in
                    self.flushOutbox(for: peerID)
                }
            }
            // Handle key updates
            if let newKey = note.userInfo?["peerPublicKey"] as? Data,
               let _ = note.userInfo?["isKeyUpdate"] as? Bool {
                let peerID = PeerID(publicKey: newKey)
                Task { @MainActor in
                    self.flushOutbox(for: peerID)
                }
            }
        }
    }

    func sendPrivate(_ content: String, to peerID: PeerID, recipientNickname: String, messageID: String) {
        let reachableMesh = mesh.isPeerReachable(peerID)
        if reachableMesh {
            SecureLogger.debug("Routing PM via mesh (reachable) to \(peerID.id.prefix(8))… id=\(messageID.prefix(8))…", category: .session)
            // BLEService will initiate a handshake if needed and queue the message
            mesh.sendPrivateMessage(content, to: peerID, recipientNickname: recipientNickname, messageID: messageID)
        } else if canSendViaNostr(peerID: peerID) {
            SecureLogger.debug("Routing PM via Nostr to \(peerID.id.prefix(8))… id=\(messageID.prefix(8))…", category: .session)
            nostr.sendPrivateMessage(content, to: peerID, recipientNickname: recipientNickname, messageID: messageID)
        } else {
            // Queue for later (when mesh connects or Nostr mapping appears)
            if outbox[peerID] == nil { outbox[peerID] = [] }
            outbox[peerID]?.append((content, recipientNickname, messageID))
            SecureLogger.debug("Queued PM for \(peerID.id.prefix(8))… (no mesh, no Nostr mapping) id=\(messageID.prefix(8))…", category: .session)
        }
    }

    func sendReadReceipt(_ receipt: ReadReceipt, to peerID: PeerID) {
        // Prefer mesh for reachable peers; BLE will queue if handshake is needed
        if mesh.isPeerReachable(peerID) {
            SecureLogger.debug("Routing READ ack via mesh (reachable) to \(peerID.id.prefix(8))… id=\(receipt.originalMessageID.prefix(8))…", category: .session)
            mesh.sendReadReceipt(receipt, to: peerID)
        } else {
            SecureLogger.debug("Routing READ ack via Nostr to \(peerID.id.prefix(8))… id=\(receipt.originalMessageID.prefix(8))…", category: .session)
            nostr.sendReadReceipt(receipt, to: peerID)
        }
    }

    func sendDeliveryAck(_ messageID: String, to peerID: PeerID) {
        if mesh.isPeerReachable(peerID) {
            SecureLogger.debug("Routing DELIVERED ack via mesh (reachable) to \(peerID.id.prefix(8))… id=\(messageID.prefix(8))…", category: .session)
            mesh.sendDeliveryAck(for: messageID, to: peerID)
        } else {
            nostr.sendDeliveryAck(for: messageID, to: peerID)
        }
    }

    func sendFavoriteNotification(to peerID: PeerID, isFavorite: Bool) {
        // Route via mesh when connected; else use Nostr
        if mesh.isPeerConnected(peerID) {
            mesh.sendFavoriteNotification(to: peerID, isFavorite: isFavorite)
        } else {
            nostr.sendFavoriteNotification(to: peerID, isFavorite: isFavorite)
        }
    }

    // MARK: - Outbox Management
    private func canSendViaNostr(peerID: PeerID) -> Bool {
        // Two forms are supported:
        // - 64-hex Noise public key (32 bytes)
        // - 16-hex short peer ID (derived from Noise pubkey)
        if let noiseKey = peerID.noiseKey {
            if let fav = FavoritesPersistenceService.shared.getFavoriteStatus(for: noiseKey),
               fav.peerNostrPublicKey != nil {
                return true
            }
        } else if peerID.isShort {
            if let fav = FavoritesPersistenceService.shared.getFavoriteStatus(forPeerID: peerID),
               fav.peerNostrPublicKey != nil {
                return true
            }
        }
        return false
    }

    func flushOutbox(for peerID: PeerID) {
        guard let queued = outbox[peerID], !queued.isEmpty else { return }
        SecureLogger.debug("Flushing outbox for \(peerID.id.prefix(8))… count=\(queued.count)", category: .session)
        var remaining: [(content: String, nickname: String, messageID: String)] = []
        // Prefer mesh if connected; else try Nostr if mapping exists
        for (content, nickname, messageID) in queued {
            if mesh.isPeerReachable(peerID) {
                SecureLogger.debug("Outbox -> mesh for \(peerID.id.prefix(8))… id=\(messageID.prefix(8))…", category: .session)
                mesh.sendPrivateMessage(content, to: peerID, recipientNickname: nickname, messageID: messageID)
            } else if canSendViaNostr(peerID: peerID) {
                SecureLogger.debug("Outbox -> Nostr for \(peerID.id.prefix(8))… id=\(messageID.prefix(8))…", category: .session)
                nostr.sendPrivateMessage(content, to: peerID, recipientNickname: nickname, messageID: messageID)
            } else {
                // Keep unsent items queued
                remaining.append((content, nickname, messageID))
            }
        }
        // Persist only items we could not send
        if remaining.isEmpty {
            outbox.removeValue(forKey: peerID)
        } else {
            outbox[peerID] = remaining
        }
    }

    func flushAllOutbox() {
        for key in Array(outbox.keys) { flushOutbox(for: key) }
    }
}
