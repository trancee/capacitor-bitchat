import Foundation
import Capacitor

@objc public class ReceivedEvent: MessageIDEvent {
    let message: String

    let peerID: String?

    let isPrivate: Bool?
    let isRelay: Bool?

    init(_ messageID: UUID?, _ message: String, _ peerID: String?, _ isPrivate: Bool?, _ isRelay: Bool?) {
        self.message = message

        self.peerID = peerID

        self.isPrivate = isPrivate
        self.isRelay = isRelay

        super.init(messageID)
    }

    override public func toJSObject() -> JSObject {
        var result = super.toJSObject()

        result["message"] = message

        if let peerID = peerID {
            result["peerID"] = peerID
        }

        if let isPrivate = isPrivate {
            result["isPrivate"] = isPrivate
        }

        if let isRelay = isRelay {
            result["isRelay"] = isRelay
        }

        return result
    }
}
