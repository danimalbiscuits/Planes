import Foundation

struct AnyDecodable: Decodable {
    var value: Any

    init(from decoder: Decoder) throws {
        if let intValue = try? decoder.singleValueContainer().decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? decoder.singleValueContainer().decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? decoder.singleValueContainer().decode(String.self) {
            value = stringValue
        } else if let boolValue = try? decoder.singleValueContainer().decode(Bool.self) {
            value = boolValue
        } else {
            value = try decoder.singleValueContainer().decodeNil() ? NSNull() : ""
        }
    }
}

