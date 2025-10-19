import Foundation

public class BitchatHelper {

    static func makeBoolean(_ value: String?) -> Bool? {
        guard let value = value, !value.isEmpty else {
            return nil
        }

        return NSString(string: value).boolValue
    }

    static func makeUUID(_ value: String?) -> UUID? {
        guard var value = value, !value.isEmpty else {
            return nil
        }

        if value.count == 32 {
            value = value.uppercased()
            value = value[0..<8] + "-" + value[8..<12] + "-" + value[12..<16] + "-" + value[16..<20] + "-" + value[20..<32]
        }

        return UUID(uuidString: value)
    }

    static func makeData(_ value: String?) -> Data? {
        guard let value = value, !value.isEmpty else {
            return nil
        }

        return Data(base64Encoded: value)
    }
}

extension String {
    subscript(range: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
}

typealias Helper = BitchatHelper
