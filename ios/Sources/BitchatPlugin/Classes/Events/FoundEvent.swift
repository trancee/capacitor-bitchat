import Foundation
import Capacitor

@objc public class FoundEvent: PeerIDEvent {
    let message: String

    init(_ peerID: String, _ message: String) {
        self.message = message

        super.init(peerID)
    }

    override public func toJSObject() -> JSObject {
        var result = super.toJSObject()

        result["message"] = message

        return result
    }
}
