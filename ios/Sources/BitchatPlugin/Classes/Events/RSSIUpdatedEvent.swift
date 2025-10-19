import Foundation
import Capacitor

@objc public class RSSIUpdatedEvent: PeerIDEvent {
    let rssi: Int

    init(_ peerID: String, _ rssi: Int) {
        self.rssi = rssi

        super.init(peerID)
    }

    override public func toJSObject() -> JSObject {
        var result = super.toJSObject()

        result["rssi"] = rssi

        return result
    }
}
