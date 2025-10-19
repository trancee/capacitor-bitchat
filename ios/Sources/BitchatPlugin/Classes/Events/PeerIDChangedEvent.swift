import Foundation
import Capacitor

@objc public class PeerIDChangedEvent: PeerIDEvent {
    let oldPeerID: String?
    let message: String

    init(_ peerID: String, _ oldPeerID: String?, _ message: String) {
        self.oldPeerID = oldPeerID
        self.message = message

        super.init(peerID)
    }

    override public func toJSObject() -> JSObject {
        var result = super.toJSObject()

        if let oldPeerID = oldPeerID {
            result["oldPeerID"] = oldPeerID
        }

        result["message"] = message

        return result
    }
}
