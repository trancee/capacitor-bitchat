import Foundation
import Capacitor

@objc public class InitializeOptions: NSObject {
    private var announceInterval: Int?

    init(_ call: CAPPluginCall) {
        super.init()

        if let announceInterval = call.getInt("announceInterval") {
            self.setAnnounceInterval(announceInterval)
        }
    }

    func setAnnounceInterval(_ announceInterval: Int?) {
        self.announceInterval = announceInterval
    }

    func getAnnounceInterval() -> Int? {
        return self.announceInterval
    }
}
