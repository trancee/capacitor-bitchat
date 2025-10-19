import Capacitor

public class BitchatConfig {
    private var announceInterval: Int?

    init(announceInterval: Int?) {
        self.setAnnounceInterval(announceInterval)
    }

    func setAnnounceInterval(_ announceInterval: Int?) {
        self.announceInterval = announceInterval
    }

    func getAnnounceInterval() -> Int? {
        return self.announceInterval
    }
}
