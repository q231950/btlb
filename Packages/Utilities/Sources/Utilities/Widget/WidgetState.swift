//
//  WidgetState.swift
//  
//
//  Created by Martin Kim Dung-Pham on 30.11.22.
//

import Foundation
import WidgetKit
import Localization
import LibraryCore

public enum WidgetState: Codable {

    case accountInfo(viewModel: AccountInfoViewModel)
    case content(viewModel: ContentViewModel)

    public struct AccountInfoViewModel: Codable {

        public let accountsCount: Int
        public let activatedAccountsCount: Int

        public init(accountsCount: Int, activatedAccountsCount: Int) {
            self.accountsCount = accountsCount
            self.activatedAccountsCount = activatedAccountsCount
        }
    }

    public class ContentViewModel: Codable, ObservableObject {

        /// The last time accounts were updated
        public let lastUpdate: Date

        public let overallNumberOfLoans: Int
        public let numberOfAccounts: Int

        public let items: [Item]

        public var hasMoreItems: Bool {
            overallNumberOfLoans > items.count
        }

        /// The date the next return of a borrowed item is due
        private let nextReturnDate: Date?

        public init(lastUpdate: Date, nextReturnDate: Date?, overallNumberOfLoans: Int, numberOfAccounts: Int, items: [Item]) {
            self.lastUpdate = lastUpdate
            self.nextReturnDate = nextReturnDate
            self.overallNumberOfLoans = overallNumberOfLoans
            self.numberOfAccounts = numberOfAccounts
            self.items = items
        }

        public var daysUntilNextReturnDateText: String {
            guard let nextReturnDate else { return "🐼" }
            return Localization.daysText(between: nextReturnDate, and: .now)
        }

        public func daysUntilNextReturnDateSubtitle(for widgetFamily: WidgetFamily) -> String {
            guard nextReturnDate != nil else { return "no item to return".localized(bundle: .localization) }

            switch widgetFamily {
            case .systemSmall:
                return "until next return date".localized(bundle: .localization)
            default:
                return "until next return date long".localized(bundle: .localization)
            }
        }

        public var daysUntilNextReturnDateDigits: String {
            guard let nextReturnDate else { return "🐼" }

            return "\(Calendar.current.numberOfDaysBetween(Date(), and: nextReturnDate))"
        }
    }


}

public extension Localization {
    /// Calculate the number of days between 2 dates
    /// Returns "1 day" or "23 days"
    static func daysText(between date: Date, and currentDate: Date) -> String {
        let days = Calendar.current.numberOfDaysBetween(currentDate, and: date)

        return "\(days) \(days == 1 ? "day".localized(bundle: .localization) : "days".localized(bundle: .localization))"
    }
}
