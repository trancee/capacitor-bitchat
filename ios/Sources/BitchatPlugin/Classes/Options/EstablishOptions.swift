import Foundation
import Capacitor

@objc public class EstablishOptions: NSObject {
    private var peerID: String?

    init(_ call: CAPPluginCall) {
        super.init()

        if let peerID = call.getString("peerID") {
            self.setPeerID(peerID)
        }
    }

    func setPeerID(_ peerID: String?) {
        self.peerID = peerID
    }

    func getPeerID() -> String? {
        return self.peerID
    }
}
