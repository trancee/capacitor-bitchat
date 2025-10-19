import Foundation
import Capacitor

@objc public class SentEvent: MessageIDEvent {
    let peerID: String?

    init(_ messageID: UUID, _ peerID: String?) {
        self.peerID = peerID

        super.init(messageID)
    }

    override public func toJSObject() -> JSObject {
        var result = super.toJSObject()

        if let peerID = peerID {
            result["peerID"] = peerID
        }

        return result
    }
}
