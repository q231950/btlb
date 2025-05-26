//
//  Configuration.swift
//  
//
//  Created by Martin Kim Dung-Pham on 16.12.22.
//
//
import Foundation

///  Configuration based on https://nshipster.com/xcconfig/
enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

public enum API {

    /// The url to send device tokens to
    public static var pushNotificationServerUrl: URL {
        return try! URL(string: Configuration.value(for: "PUSH_NOTIFICATION_SERVER_URL") as String)!
    }
}
