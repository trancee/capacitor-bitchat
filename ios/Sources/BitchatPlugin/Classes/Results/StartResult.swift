import Foundation
import Capacitor

@objc public class StartResult: NSObject, Result {
    let peerID: String?

    init(_ peerID: String?) {
        self.peerID = peerID
    }

    public func toJSObject() -> AnyObject {
        var result = JSObject()

        if let peerID = peerID {
            result["peerID"] = peerID
        }

        return result as AnyObject
    }
}
