//
//  RenewableItem.swift
//  
//
//  Created by Martin Kim Dung-Pham on 29.12.22.
//

import Foundation

extension RenewableItem: Equatable {
    public static func == (lhs: RenewableItem, rhs: RenewableItem) -> Bool {
        lhs.barcode == rhs.barcode
    }
}

public struct RenewableItem {
    
    /// The current status of the item.
    public enum Status: Equatable {
        /// The item is borrowed. It's neither expiring today nor has it in the past
        case borrowed

        /// The item is expiring today.
        case expiresToday

        /// The item is expired, no matter if renewable or not
        case expired
    }

    public let title: String
    public let barcode: String
    public let canRenew: Bool
    public let expirationDate: Date
    public let expirationNotificationDate: Date?
    public let onExpirationNotificationScheduled: (Date?) async -> Void
    private let now: Date

    public static private(set) var placeholder: RenewableItem = {
        RenewableItem(now: .now, title: "", barcode: "", canRenew: false, expirationDate: .now, expirationNotificationDate: nil) { _ in }
    }()

    /// Initialize a RenewableItem.
    ///
    /// - Parameters:
    ///   - now: the date time that is supposed to be 'now' (might not be now in a test)
    ///   - title: the title of the item, something like "Do Androids dream of electric Sheep"
    ///   - barcode: a unique identifier
    ///   - canRenew: whether or not the item can be renewed
    ///   - expirationDate: the date when the item will or has expired
    ///   - expirationNotificationDate: the date when the notification for this item was scheduled by the app
    ///   - onExpirationNotificationScheduled: <#onExpirationNotificationScheduled description#>
    public init(now: Date, title: String, barcode: String, canRenew: Bool, expirationDate: Date, expirationNotificationDate: Date?, onExpirationNotificationScheduled: @escaping (Date?) async -> Void) {
        self.now = now
        self.title = title
        self.barcode = barcode
        self.canRenew = canRenew
        self.expirationDate = expirationDate
        self.expirationNotificationDate = expirationNotificationDate
        self.onExpirationNotificationScheduled = onExpirationNotificationScheduled
    }

    public var status: Status {
        if expirationIsToday {
            return .expiresToday
        } else if expirationDate < .now {
            return .expired
        } else {
            return .borrowed
        }
    }

    private var expirationIsToday: Bool {
        Calendar.current.isDateInToday(expirationDate)
    }
}
