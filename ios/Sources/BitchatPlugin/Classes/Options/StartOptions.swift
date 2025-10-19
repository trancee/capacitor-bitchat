import Foundation
import Capacitor

@objc public class StartOptions: NSObject {
    private var message: String?

    init(_ call: CAPPluginCall) {
        super.init()

        if let message = call.getString("message") {
            self.setMessage(message)
        }
    }

    func setMessage(_ message: String?) {
        self.message = message
    }

    func getMessage() -> String? {
        return self.message
    }
}
