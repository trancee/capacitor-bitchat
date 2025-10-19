import Foundation
import Capacitor

@objc public class PermissionsResult: NSObject, Result {
    let bluetooth: String
    let location: String?
    let battery: String?

    init(bluetooth: String, location: String? = nil, battery: String? = nil) {
        self.bluetooth = bluetooth
        self.location = location
        self.battery = battery
    }

    public func toJSObject() -> AnyObject {
        var result = JSObject()

        result["bluetooth"] = bluetooth

        if let location = location {
            result["location"] = location
        }
        if let battery = battery {
            result["battery"] = battery
        }

        return result as AnyObject
    }
}
