import Foundation
import Capacitor

@objc public class PeerIDEvent: NSObject {
    let peerID: String

    init(_ peerID: String) {
        self.peerID = peerID
    }

    public func toJSObject() -> JSObject {
        var result = JSObject()

        result["peerID"] = peerID

        return result
    }
}
