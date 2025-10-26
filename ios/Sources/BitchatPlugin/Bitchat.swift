import Foundation
import Capacitor
import CoreBluetooth

@objc public class Bitchat: NSObject, BitchatDelegate {
    private var isInitialized: Bool = false
    private var isStarted: Bool = false

    private var nickname: String?

    private let plugin: BitchatPlugin
    private let config: BitchatConfig?

    private let meshService: BLEService
    private let identityManager: SecureIdentityStateManagerProtocol

    init(plugin: BitchatPlugin, config: BitchatConfig?) {
        self.plugin = plugin
        self.config = config

        let keychain: KeychainManager = KeychainManager()
        identityManager = SecureIdentityStateManager(keychain)

        self.meshService = BLEService(keychain: keychain, identityManager: identityManager)

        super.init()
    }

    deinit {
        stop {_ in}
    }

    /**
     * Initialize
     */

    @objc public func initialize(_ options: InitializeOptions, completion: @escaping (Result?, Error?) -> Void) {
        meshService.delegate = self

        if let announceInterval = options.getAnnounceInterval() ?? config?.getAnnounceInterval() {
            meshService.announceInterval = TimeInterval(announceInterval)
        }

        do {
            isInitialized = true

            let peerID = meshService.myPeerID.id

            let result = InitializeResult(peerID)
            completion(result, nil)
        } catch {
            completion(nil, error)
        }
    }

    @objc public func isInitialized(completion: @escaping (Result?, Error?) -> Void) {
        let result = IsInitializedResult(isInitialized)
        completion(result, nil)
    }

    @objc public func start(_ options: StartOptions, completion: @escaping (Result?, Error?) -> Void) {
        if !isInitialized {
            return completion(nil, CustomError.notInitialized)
        }

        if let message = options.getMessage() {
            nickname = message
        }

        do {
            // Set nickname before starting services
            if let nickname {
                meshService.setNickname(nickname)
            }

            // Start mesh service immediately
            meshService.startServices()

            let peerID = meshService.myPeerID.id

            let result = StartResult(peerID)
            completion(result, nil)
        } catch {
            completion(nil, error)
        }
    }

    @objc public func isStarted(completion: @escaping (Result?, Error?) -> Void) {
        let result = IsStartedResult(isStarted)
        completion(result, nil)
    }

    @objc public func stop(completion: @escaping (Error?) -> Void) {
        do {
            meshService.stopServices()

            completion(nil)
        } catch {
            completion(error)
        }
    }

    /**
     * Session
     */

    @objc public func establish(_ options: EstablishOptions, completion: @escaping (Result?, Error?) -> Void) {
        if !isInitialized {
            return completion(nil, CustomError.notInitialized)
        }
        if !isStarted {
            return completion(nil, CustomError.notStarted)
        }

        guard let peerID = options.getPeerID() else {
            return completion(nil, CustomError.peerIDMissing)
        }

        do {
            if !(meshService.hasEstablishedSession(with: PeerID(str: peerID))) {
                meshService.triggerHandshake(with: PeerID(str: peerID))
            }

            let isEstablished = meshService.hasEstablishedSession(with: PeerID(str: peerID))

            let result = EstablishResult(isEstablished)
            completion(result, nil)
        } catch {
            completion(nil, error)
        }
    }

    @objc public func isEstablished(_ options: IsEstablishedOptions, completion: @escaping (Result?, Error?) -> Void) {
        guard let peerID = options.getPeerID() else {
            return completion(nil, CustomError.peerIDMissing)
        }

        let isEstablished = meshService.hasEstablishedSession(with: PeerID(str: peerID))

        let result = IsEstablishedResult(isEstablished)
        completion(result, nil)
    }

    /**
     * Payload
     */

    @objc public func send(_ options: SendOptions, completion: @escaping (Result?, Error?) -> Void) {
        if !isInitialized {
            return completion(nil, CustomError.notInitialized)
        }
        if !isStarted {
            return completion(nil, CustomError.notStarted)
        }

        guard let message = options.getMessage() else {
            return completion(nil, CustomError.payloadMissing)
        }

        do {
            let messageID = UUID()

            if let peerID = options.getPeerID() {
                meshService.sendMessage(message, to: PeerID(str: peerID), messageID: messageID.uuidString.lowercased())
            } else {
                meshService.sendMessage(message, messageID: messageID.uuidString.lowercased())
            }

            let result = SendResult(messageID)
            completion(result, nil)
        } catch {
            completion(nil, error)
        }
    }

    /**
     Delegate
     */

    // MARK: - Message Reception

    func didReceiveMessage(_ message: BitchatMessage) {
        // Route to appropriate handler
        if message.isPrivate {
            SecureLogger.debug("📥 handlePrivateMessage called for message from \(message.sender)", category: .session)
        } else {
            SecureLogger.debug("📥 handlePublicMessage called for message from \(message.sender)", category: .session)
        }

        let messageID = message.id
        let content = message.content
        let peerID = message.sender

        let isPrivate = message.isPrivate
        let isRelay = message.isRelay

        plugin.onReceivedEvent(messageID: Helper.makeUUID(messageID), content, peerID: peerID, isPrivate: isPrivate, isRelay: isRelay)
    }

    // MARK: - Peer Connection Events

    func didConnectToPeer(_ peerID: PeerID) {
        SecureLogger.debug("🤝 Peer connected: \(peerID)", category: .session)

        // Register ephemeral session with identity manager
        identityManager.registerEphemeralSession(peerID: peerID, handshakeState: .none)
    }

    func didDisconnectFromPeer(_ peerID: PeerID) {
        SecureLogger.debug("👋 Peer disconnected: \(peerID)", category: .session)

        // Remove ephemeral session from identity manager
        identityManager.removeEphemeralSession(peerID: peerID)
    }

    func didUpdatePeerList(_ peers: [PeerID]) {
    }

    func didUpdateBluetoothState(_ state: CBManagerState) {
    }

    func onStarted(_ peerID: PeerID, success: Bool?) {
        let peerID = peerID.id

        if let success {
            isStarted = success
        }

        plugin.onStartedEvent(peerID, isStarted: success)
    }

    func onStopped() {
        isStarted = false

        plugin.onStoppedEvent()
    }

    func onFound(_ peerID: PeerID, nickname: String) {
        let peerID = peerID.id

        plugin.onFoundEvent(peerID, message: nickname)
    }

    func onLost(_ peerID: PeerID) {
        let peerID = peerID.id

        plugin.onLostEvent(peerID)
    }

    func onConnected(_ peerID: PeerID) {
        let peerID = peerID.id

        plugin.onConnectedEvent(peerID)
    }

    func onDisconnected(_ peerID: PeerID) {
        let peerID = peerID.id

        plugin.onDisconnectedEvent(peerID)
    }

    func onEstablished(_ peerID: PeerID) {
        let peerID = peerID.id

        plugin.onEstablishedEvent(peerID)
    }

    func onSent(_ messageID: String, peerID: PeerID?) {
        guard let messageID = Helper.makeUUID(messageID) else { return }

        if let peerID = peerID {
            plugin.onSentEvent(messageID, peerID: peerID.id)
        } else {
            plugin.onSentEvent(messageID)
        }
    }

    func onRSSIUpdated(_ peerID: PeerID, rssi: Int) {
        let peerID = peerID.id

        plugin.onRSSIUpdatedEvent(peerID, rssi)
    }

    func onPeerInfoUpdated(_ peerID: PeerID, nickname: String, isVerified: Bool) {
    }

    func onPeerIDChanged(_ peerID: PeerID, oldPeerID: String?, nickname: String) {
    }

    /**
     * Permissions
     */

    private func bluetoothAuthorization() -> CBManagerAuthorization {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization
        } else if #available(iOS 13.0, *) {
            return CBCentralManager().authorization
        }
    }

    private func bluetoothState() -> CBManagerState {
        return CBCentralManager().state
    }

    @objc public func checkPermissions(completion: @escaping (Result?, Error?) -> Void) {
        let bluetoothState = switch bluetoothAuthorization() {
        case .notDetermined:
            "prompt"
        case .restricted, .denied:
            "denied"
        case .allowedAlways:
            "granted"
        @unknown default:
            "prompt"
        }

        let result = PermissionsResult(bluetooth: bluetoothState)

        completion(result, nil)
    }

    @objc public func requestPermissions(_ options: RequestPermissionsOptions, completion: @escaping (Result?, Error?) -> Void) {
        var permissions = options.getPermissions() ?? []

        if permissions.isEmpty {
            permissions = ["bluetooth"]
        }

        let group = DispatchGroup()

        if permissions.contains("bluetooth") {
            if bluetoothState() == .poweredOff {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    completion(nil, CustomError.openSettingsError)
                    return
                }

                DispatchQueue.main.async {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        group.enter()

                        UIApplication.shared.open(settingsUrl, completionHandler: { (_) in
                            group.leave()
                        })
                    } else {
                        completion(nil, CustomError.openSettingsError)
                        return
                    }
                }
            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.checkPermissions(completion: completion)
        }
    }
}
