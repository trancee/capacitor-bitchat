import Foundation
import Capacitor

@objc public class SendOptions: NSObject {
    private var message: String?
    private var peerID: String?

    init(_ call: CAPPluginCall) {
        super.init()

        if let message = call.getString("message") {
            self.setMessage(message)
        }

        if let peerID = call.getString("peerID") {
            self.setPeerID(peerID)
        }
    }

    func setMessage(_ message: String?) {
        self.message = message
    }

    func getMessage() -> String? {
        return self.message
    }

    func setPeerID(_ peerID: String?) {
        self.peerID = peerID
    }

    func getPeerID() -> String? {
        return self.peerID
    }
}
