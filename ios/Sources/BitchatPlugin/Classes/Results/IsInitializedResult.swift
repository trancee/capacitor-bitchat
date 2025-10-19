import Foundation
import Capacitor

@objc public class IsInitializedResult: NSObject, Result {
    let isInitialized: Bool?

    init(_ isInitialized: Bool?) {
        self.isInitialized = isInitialized
    }

    public func toJSObject() -> AnyObject {
        var result = JSObject()

        if let isInitialized = isInitialized {
            result["isInitialized"] = isInitialized
        }

        return result as AnyObject
    }
}
