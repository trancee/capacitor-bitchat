import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(BitchatPlugin)
public class BitchatPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "BitchatPlugin"
    public let jsName = "Bitchat"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "initialize", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isInitialized", returnType: CAPPluginReturnPromise),

        CAPPluginMethod(name: "start", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isStarted", returnType: CAPPluginReturnPromise),

        CAPPluginMethod(name: "stop", returnType: CAPPluginReturnPromise),

        CAPPluginMethod(name: "establish", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isEstablished", returnType: CAPPluginReturnPromise),

        CAPPluginMethod(name: "send", returnType: CAPPluginReturnPromise),

        CAPPluginMethod(name: "checkPermissions", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestPermissions", returnType: CAPPluginReturnPromise)
    ]

    public let tag = "BitchatPlugin"

    // Initialization Listeners

    let eventStarted = "onStarted"
    let eventStopped = "onStopped"

    // Connectivity Listeners

    let eventFound = "onFound"
    let eventLost = "onLost"

    let eventConnected = "onConnected"
    let eventDisconnected = "onDisconnected"
    let eventEstablished = "onEstablished"

    // Transmission Listeners

    let eventSent = "onSent"
    let eventReceived = "onReceived"

    let eventRSSIUpdated = "onRSSIUpdated"

    let eventPeerListUpdated = "onPeerListUpdated"
    let eventPeerIDChanged = "onPeerIDChanged"

    private var implementation: Bitchat?

    override public func load() {
        super.load()

        let config = getBitchatConfig()

        self.implementation = Bitchat(plugin: self, config: config)
    }

    /**
     * Initialize
     */

    @objc func initialize(_ call: CAPPluginCall) {
        let options = InitializeOptions(call)

        implementation?.initialize(options, completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    @objc func isInitialized(_ call: CAPPluginCall) {
        implementation?.isInitialized(completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    @objc func start(_ call: CAPPluginCall) {
        let options = StartOptions(call)

        implementation?.start(options, completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    @objc func isStarted(_ call: CAPPluginCall) {
        implementation?.isStarted(completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    @objc func stop(_ call: CAPPluginCall) {
        implementation?.stop(completion: { error in
            if let error = error {
                self.rejectCall(call, error)
            } else {
                self.resolveCall(call)
            }
        })
    }

    /**
     * Session
     */

    @objc func establish(_ call: CAPPluginCall) {
        let options = EstablishOptions(call)

        implementation?.establish(options, completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    @objc func isEstablished(_ call: CAPPluginCall) {
        let options = IsEstablishedOptions(call)

        implementation?.isEstablished(options, completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    /**
     * Payload
     */

    @objc func send(_ call: CAPPluginCall) {
        let options = SendOptions(call)

        implementation?.send(options, completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    /**
     * Permissions
     */

    @objc override public func checkPermissions(_ call: CAPPluginCall) {
        implementation?.checkPermissions(completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    @objc override public func requestPermissions(_ call: CAPPluginCall) {
        let options = RequestPermissionsOptions(call)

        implementation?.requestPermissions(options, completion: { result, error in
            if let error = error {
                self.rejectCall(call, error)
            } else if let result = result?.toJSObject() as? JSObject {
                self.resolveCall(call, result)
            }
        })
    }

    /**
     * Initialization Listeners
     */

    func onStartedEvent(_ peerID: String, isStarted: Bool?) {
        let event: StartedEvent = .init(peerID, isStarted)

        notifyListeners(self.eventStarted, data: event.toJSObject())
    }

    func onStoppedEvent() {
        let event: StoppedEvent = .init()

        notifyListeners(self.eventStopped, data: event.toJSObject())
    }

    /**
     * Connectivity Listeners
     */

    func onFoundEvent(_ peerID: String, message: String) {
        let event: FoundEvent = .init(peerID, message)

        notifyListeners(self.eventFound, data: event.toJSObject())
    }

    func onLostEvent(_ peerID: String) {
        let event: LostEvent = .init(peerID)

        notifyListeners(self.eventLost, data: event.toJSObject())
    }

    func onConnectedEvent(_ peerID: String) {
        let event: ConnectedEvent = .init(peerID)

        notifyListeners(self.eventConnected, data: event.toJSObject())
    }

    func onDisconnectedEvent(_ peerID: String) {
        let event: DisconnectedEvent = .init(peerID)

        notifyListeners(self.eventDisconnected, data: event.toJSObject())
    }

    func onEstablishedEvent(_ peerID: String) {
        let event: EstablishedEvent = .init(peerID)

        notifyListeners(self.eventEstablished, data: event.toJSObject())
    }

    /**
     * Transmission Listeners
     */

    func onSentEvent(_ messageID: UUID, peerID: String) {
        let event: SentEvent = .init(messageID, peerID)

        notifyListeners(self.eventSent, data: event.toJSObject())
    }

    func onReceivedEvent(_ message: String, peerID: String?) {
        onReceivedEvent(messageID: nil, message, peerID: peerID, isPrivate: nil, isRelay: nil)
    }

    func onReceivedEvent(messageID: UUID?, _ message: String, peerID: String?, isPrivate: Bool?, isRelay: Bool?) {
        let event: ReceivedEvent = .init(messageID, message, peerID, isPrivate, isRelay)

        notifyListeners(self.eventReceived, data: event.toJSObject())
    }

    func onRSSIUpdatedEvent(_ peerID: String, _ rssi: Int) {
        let event: RSSIUpdatedEvent = .init(peerID, rssi)

        notifyListeners(self.eventRSSIUpdated, data: event.toJSObject())
    }

    func onPeerIDChangedEvent(peerID: String, oldPeerID: String?, _ message: String) {
        let event: PeerIDChangedEvent = .init(peerID, oldPeerID, message)

        notifyListeners(self.eventReceived, data: event.toJSObject())
    }

    /**
     Configuration
     */

    func getBitchatConfig() -> BitchatConfig? {
        let announceInterval = getConfig().getConfigJSON()["announceInterval"] as? Int

        return BitchatConfig(announceInterval: announceInterval)
    }

    /**
     * Calls
     */

    private func rejectCall(_ call: CAPPluginCall, _ error: Error) {
        CAPLog.print("[", self.tag, "] ", error)
        call.reject(error.localizedDescription)
    }

    private func resolveCall(_ call: CAPPluginCall, _ result: JSObject? = nil) {
        if let result {
            call.resolve(result)
        } else {
            call.resolve()
        }
    }
}
