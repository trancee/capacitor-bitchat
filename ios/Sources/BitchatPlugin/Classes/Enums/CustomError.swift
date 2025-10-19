import Foundation

public enum CustomError: Error {
    case notInitialized
    case notStarted

    case peerIDMissing
    case payloadMissing

    case openSettingsError
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return NSLocalizedString("not initialized", comment: "notInitialized")
        case .notStarted:
            return NSLocalizedString("not started", comment: "notStarted")

        case .peerIDMissing:
            return NSLocalizedString("missing peer identifier", comment: "peerIDMissing")
        case .payloadMissing:
            return NSLocalizedString("missing payload", comment: "payloadMissing")

        case .openSettingsError:
            return NSLocalizedString("open settings error", comment: "openSettingsError")
        }
    }
}
