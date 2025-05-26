import Foundation
import SwiftUI

public extension Bundle {
    static var localization: Bundle {
        .module
    }
}

public struct Localization {

    public static func localized(_ value: String.LocalizationValue, in bundle: Bundle?) -> String {
        String(localized: value, table: nil, bundle: bundle ?? Bundle.module, locale: .current, comment: nil)
    }

    public enum Titles: LocalizableByTable {
        public static var accounts = "Accounts".localized(table: table)
        public static var bookmarks = "Bookmarks".localized(table: table)
        public static var charges = "Charges".localized(table: table)
        public static var loans = "Loans".localized(table: table)
        public static var more = "More".localized(table: table)
        public static var search = "Search".localized(table: table)
        public static var about = "About".localized(table: table)
        public static var settings = "Settings".localized(table: table)

        public static var table: String {
            "Titles"
        }
    }

    public enum Accounts: LocalizableByTable {
        public static let emptyHint: LocalizedStringKey = "no accounts hint text"
        public static let addAccountButtonTitle: LocalizedStringKey = "no accounts add account button title"

        public static var table: String {
            "Accounts"
        }
    }

    public enum Bookmarks: LocalizableByTable {

        public static let deleteBookmarkButton = "delete bookmark button".localized(table: table)
        public static let emptyHint = "no bookmarks hint text".localized(table: table)
        public static let emptySearchResult = "empty search result hint text".localized(table: table)

        public static var table: String {
            "Bookmarks"
        }
    }

    public enum Charges: LocalizableByTable {

        public enum Text {
            public static let sum = "sum text".localized(table: table)
            public static let zeroCharges = "zero charges text".localized(table: table)
            public static let paid = "paid text".localized(table: table)
        }

        public static var table: String {
            "Charges"
        }
    }

    public enum Loans {
        public enum Text: LocalizableByTable {
            public static let notificationTriggerItemExpiresTodayDescription = "notification item expires today description text".localized(table: table)

            public static let notificationTriggerItemExpiresTomorrowDescription = "notification item expires tomorrow description text".localized(table: table)

            public static func notificationTriggerDateDescription(_ date: Date) -> String {
                let format = "notification trigger date description text".localized(table: table) as NSString
                let formattedDate = date.formatted(date: .long, time: .omitted)

                return NSString.localizedStringWithFormat(format, formattedDate) as String
            }

            public static func notificationTriggerItemExpiredDescription(_ date: Date) -> String {
                let format = "notification trigger expired item".localized(table: table) as NSString
                let formattedDate = date.formatted(date: .long, time: .omitted)

                return NSString.localizedStringWithFormat(format, formattedDate) as String
            }

            public static var table: String {
                "Loans"
            }
        }

        public enum Accessibility: LocalizableByTable {
            public static let bookmark = "accessibility bookmark".localized(table: table)
            public static let removeBookmark = "accessibility unbookmark".localized(table: table)
            public static let renew = "accessibility renew".localized(table: table)
            public static let renewed = "accessibility renewed".localized(table: table)
            public static let notRenewable = "accessibility not renewable".localized(table: table)

            public static var table: String {
                "Loans"
            }
        }
    }

    public enum Search {
        public enum Text: LocalizableByTable {
            public static func searchHits(_ count: Int) -> String {
                let format = "search hits".localized(table: table) as NSString
                return NSString.localizedStringWithFormat(format, count) as String

            }

            public static var table: String {
                "Search"
            }
        }
    }

    public enum Settings {
        public enum Text: LocalizableByTable {
            public static let day = "day".localized(table: table)
            public static let days = "days".localized(table: table)

            public static var table: String {
                "Settings"
            }
        }
    }

    public enum Tabbar {
        public enum Text: LocalizableByTable {
            public static let more = "More".localized(table: table)

            public static var table: String {
                "Tabbar"
            }
        }
    }

    public enum Widget {
        public enum Text {
            public static func overallNumberOfLoansText(_ loansCount: Int, accountsCount: Int) -> LocalizedStringKey {
                return switch (loansCount, accountsCount) {
                case (1, 1):
                    "overall number of loans single account single item long"
                case (1, _):
                    "overall number of loans long single item \(accountsCount)"
                case (_, 1):
                    "overall number of loans single account long \(loansCount)"
                case (_, _):
                    "overall number of loans long \(loansCount) \(accountsCount)"
                }
            }
        }
    }

    static func localized(_ value: String.LocalizationValue) -> String {
        localized(value, in: .module)
    }

}

public protocol LocalizableByTable {
    static var table: String { get }
}

extension String {

    @available(*, deprecated, message: "Use `Text(\"LIBRARIES_TEXT\", bundle: .module)` instead. Add tableName if the bundle's table is not `Localizable.xcstrings`.")
    public func localized(table: String? = nil, bundle: Bundle? = .localization) -> String {
        NSLocalizedString(self, tableName: table ?? "Localizable", bundle: bundle ?? Bundle.module, comment: "")
    }

    public func localizedKey(table: String? = nil, bundle: Bundle? = nil) -> LocalizedStringKey {
        LocalizedStringKey(NSLocalizedString(self, tableName: table ?? "Localizable", bundle: bundle ?? Bundle.module, comment: ""))
    }

    public func localizedStringResource(table: String? = nil, bundle: Bundle? =  nil) -> LocalizedStringResource {
        LocalizedStringResource(LocalizationValue(stringLiteral: self), table: table, bundle: LocalizedStringResource.BundleDescription.atURL((bundle ?? .module).bundleURL))
    }
}

