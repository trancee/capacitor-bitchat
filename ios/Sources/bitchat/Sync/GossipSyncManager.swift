import Foundation

// Gossip-based sync manager using on-demand GCS filters
final class GossipSyncManager {
    protocol Delegate: AnyObject {
        func sendPacket(_ packet: BitchatPacket)
        func sendPacket(to peerID: PeerID, packet: BitchatPacket)
        func signPacketForBroadcast(_ packet: BitchatPacket) -> BitchatPacket
    }

    struct Config {
        var seenCapacity: Int = 1000          // max packets per sync (cap across types)
        var gcsMaxBytes: Int = 400           // filter size budget (128..1024)
        var gcsTargetFpr: Double = 0.01      // 1%
        var maxMessageAgeSeconds: TimeInterval = 900  // 15 min - discard older messages
    }

    private let myPeerID: PeerID
    private let config: Config
    weak var delegate: Delegate?

    // Storage: broadcast messages (ordered by insert), and latest announce per sender
    private var messages: [String: BitchatPacket] = [:] // idHex -> packet
    private var messageOrder: [String] = []
    private var latestAnnouncementByPeer: [String: (id: String, packet: BitchatPacket)] = [:]

    // Timer
    private var periodicTimer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "mesh.sync", qos: .utility)

    init(myPeerID: PeerID, config: Config = Config()) {
        self.myPeerID = myPeerID
        self.config = config
    }

    func start() {
        stop()
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 30.0, repeating: 30.0, leeway: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.cleanupExpiredMessages()
            self?.sendRequestSync()
        }
        timer.resume()
        periodicTimer = timer
    }

    func stop() {
        periodicTimer?.cancel(); periodicTimer = nil
    }

    func scheduleInitialSyncToPeer(_ peerID: PeerID, delaySeconds: TimeInterval = 5.0) {
        queue.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            self?.sendRequestSync(to: peerID)
        }
    }

    func onPublicPacketSeen(_ packet: BitchatPacket) {
        queue.async { [weak self] in
            self?._onPublicPacketSeen(packet)
        }
    }

    // Helper to check if a packet is within the age threshold
    private func isPacketFresh(_ packet: BitchatPacket) -> Bool {
        let nowMs = UInt64(Date().timeIntervalSince1970 * 1000)
        let ageThresholdMs = UInt64(config.maxMessageAgeSeconds * 1000)

        // If current time is less than threshold, accept all (handle clock issues gracefully)
        guard nowMs >= ageThresholdMs else { return true }

        let cutoffMs = nowMs - ageThresholdMs
        return packet.timestamp >= cutoffMs
    }

    private func _onPublicPacketSeen(_ packet: BitchatPacket) {
        let mt = MessageType(rawValue: packet.type)
        let isBroadcastRecipient: Bool = {
            guard let r = packet.recipientID else { return true }
            return r.count == 8 && r.allSatisfy { $0 == 0xFF }
        }()
        let isBroadcastMessage = (mt == .message && isBroadcastRecipient)
        let isAnnounce = (mt == .announce)
        guard isBroadcastMessage || isAnnounce else { return }

        // Reject expired packets to prevent ghost peers and old messages
        guard isPacketFresh(packet) else { return }

        let idHex = PacketIdUtil.computeId(packet).hexEncodedString()

        if isBroadcastMessage {
            if messages[idHex] == nil {
                messages[idHex] = packet
                messageOrder.append(idHex)
                // Enforce capacity
                let cap = max(1, config.seenCapacity)
                while messageOrder.count > cap {
                    let victim = messageOrder.removeFirst()
                    messages.removeValue(forKey: victim)
                }
            }
        } else if isAnnounce {
            let sender = packet.senderID.hexEncodedString()
            latestAnnouncementByPeer[sender] = (id: idHex, packet: packet)
        }
    }

    private func sendRequestSync() {
        let payload = buildGcsPayload()
        let pkt = BitchatPacket(
            type: MessageType.requestSync.rawValue,
            senderID: Data(hexString: myPeerID.id) ?? Data(),
            recipientID: nil, // broadcast
            timestamp: UInt64(Date().timeIntervalSince1970 * 1000),
            payload: payload,
            signature: nil,
            ttl: 0 // local-only
        )
        let signed = delegate?.signPacketForBroadcast(pkt) ?? pkt
        delegate?.sendPacket(signed)
    }

    private func sendRequestSync(to peerID: PeerID) {
        let payload = buildGcsPayload()
        var recipient = Data()
        var temp = peerID.id
        while temp.count >= 2 && recipient.count < 8 {
            let hexByte = String(temp.prefix(2))
            if let b = UInt8(hexByte, radix: 16) { recipient.append(b) }
            temp = String(temp.dropFirst(2))
        }
        let pkt = BitchatPacket(
            type: MessageType.requestSync.rawValue,
            senderID: Data(hexString: myPeerID.id) ?? Data(),
            recipientID: recipient,
            timestamp: UInt64(Date().timeIntervalSince1970 * 1000),
            payload: payload,
            signature: nil,
            ttl: 0 // local-only
        )
        let signed = delegate?.signPacketForBroadcast(pkt) ?? pkt
        delegate?.sendPacket(to: peerID, packet: signed)
    }

    func handleRequestSync(from peerID: PeerID, request: RequestSyncPacket) {
        queue.async { [weak self] in
            self?._handleRequestSync(from: peerID, request: request)
        }
    }

    private func _handleRequestSync(from peerID: PeerID, request: RequestSyncPacket) {
        // Decode GCS into sorted set and prepare membership checker
        let sorted = GCSFilter.decodeToSortedSet(p: request.p, m: request.m, data: request.data)
        func mightContain(_ id: Data) -> Bool {
            let bucket = GCSFilter.bucket(for: id, modulus: request.m)
            return GCSFilter.contains(sortedValues: sorted, candidate: bucket)
        }

        // 1) Announcements: send latest per peer if requester lacks them (and not expired)
        for (_, pair) in latestAnnouncementByPeer {
            let (idHex, pkt) = pair
            guard isPacketFresh(pkt) else { continue }
            let idBytes = Data(hexString: idHex) ?? Data()
            if !mightContain(idBytes) {
                var toSend = pkt
                toSend.ttl = 0
                delegate?.sendPacket(to: peerID, packet: toSend)
            }
        }

        // 2) Broadcast messages: send all missing (and not expired)
        let toSendMsgs = messageOrder.compactMap { messages[$0] }
        for pkt in toSendMsgs {
            guard isPacketFresh(pkt) else { continue }
            let idBytes = PacketIdUtil.computeId(pkt)
            if !mightContain(idBytes) {
                var toSend = pkt
                toSend.ttl = 0
                delegate?.sendPacket(to: peerID, packet: toSend)
            }
        }
    }

    // Build REQUEST_SYNC payload using current candidates and GCS params
    private func buildGcsPayload() -> Data {
        // Collect candidates: latest announce per peer + broadcast messages (only fresh)
        var candidates: [BitchatPacket] = []
        candidates.reserveCapacity(latestAnnouncementByPeer.count + messageOrder.count)
        for (_, pair) in latestAnnouncementByPeer {
            if isPacketFresh(pair.packet) {
                candidates.append(pair.packet)
            }
        }
        for id in messageOrder {
            if let p = messages[id], isPacketFresh(p) {
                candidates.append(p)
            }
        }
        // Sort by timestamp desc
        candidates.sort { $0.timestamp > $1.timestamp }

        let p = GCSFilter.deriveP(targetFpr: config.gcsTargetFpr)
        let nMax = GCSFilter.estimateMaxElements(sizeBytes: config.gcsMaxBytes, p: p)
        let cap = max(1, config.seenCapacity)
        let takeN = min(candidates.count, min(nMax, cap))
        if takeN <= 0 {
            let req = RequestSyncPacket(p: p, m: 1, data: Data())
            return req.encode()
        }
        let ids: [Data] = candidates.prefix(takeN).map { PacketIdUtil.computeId($0) }
        let params = GCSFilter.buildFilter(ids: ids, maxBytes: config.gcsMaxBytes, targetFpr: config.gcsTargetFpr)
        let req = RequestSyncPacket(p: params.p, m: params.m, data: params.data)
        return req.encode()
    }

    // Periodic cleanup of expired messages and announcements
    private func cleanupExpiredMessages() {
        // Remove expired announcements
        latestAnnouncementByPeer = latestAnnouncementByPeer.filter { _, pair in
            isPacketFresh(pair.packet)
        }

        // Remove expired messages
        let expiredMessageIds = messages.compactMap { id, pkt in
            isPacketFresh(pkt) ? nil : id
        }
        for id in expiredMessageIds {
            messages.removeValue(forKey: id)
            messageOrder.removeAll { $0 == id }
        }
    }

    // Explicit removal hook for LEAVE/stale peer
    func removeAnnouncementForPeer(_ peerID: PeerID) {
        queue.async { [weak self] in
            self?._removeAnnouncementForPeer(peerID)
        }
    }

    private func _removeAnnouncementForPeer(_ peerID: PeerID) {
        let normalizedPeerID = peerID.id.lowercased()
        _ = latestAnnouncementByPeer.removeValue(forKey: normalizedPeerID)

        // Remove messages from this peer
        // Collect IDs to remove first to avoid concurrent modification
        let messageIdsToRemove = messages.compactMap { (id, message) -> String? in
            message.senderID.hexEncodedString().lowercased() == normalizedPeerID ? id : nil
        }
        
        // Remove messages and update messageOrder
        for id in messageIdsToRemove {
            messages.removeValue(forKey: id)
            messageOrder.removeAll { $0 == id }
        }
    }
}
