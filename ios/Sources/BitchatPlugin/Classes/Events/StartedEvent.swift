import Foundation
import Capacitor

@objc public class StartedEvent: PeerIDEvent {
    let isStarted: Bool?

    init(_ peerID: String, _ isStarted: Bool?) {
        self.isStarted = isStarted

        super.init(peerID)
    }

    override public func toJSObject() -> JSObject {
        var result = super.toJSObject()

        if let isStarted = isStarted {
            result["isStarted"] = isStarted
        }

        return result
    }
}
