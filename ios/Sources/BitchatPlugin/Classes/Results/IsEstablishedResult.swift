import Foundation
import Capacitor

@objc public class IsEstablishedResult: NSObject, Result {
    let isEstablished: Bool?

    init(_ isEstablished: Bool?) {
        self.isEstablished = isEstablished
    }

    public func toJSObject() -> AnyObject {
        var result = JSObject()

        if let isEstablished = isEstablished {
            result["isEstablished"] = isEstablished
        }

        return result as AnyObject
    }
}
