//
//  DemoAccount.swift
//  LibraryCore
//
//  Created by Martin Kim Dung-Pham on 03.11.26.
//

import Foundation

/// The demo account shows made-up loans and charges instead of the ones of a real library account.
///
/// People sign in to it at any library with the username `demo` and the password `demo`, e.g. to try the app
/// or to review it. The demo account never reaches a library:
/// - signing in always succeeds
/// - updating it loads the loans and charges of ``account(now:)``
/// - updating only the demo account and renewing its loans change nothing, so its due dates stay the ones from signing in
public enum DemoAccount {

    /// The username of the demo account
    public static let username = "demo"

    /// The password of the demo account
    public static let password = "demo"

    /// The prefix of the barcodes of the demo loans, which keeps them apart from the loans of real accounts
    public static let barcodePrefix = "DEMO-"

    /// Whether the given credentials are the ones of the demo account.
    ///
    /// Both the username and the password need to match, so a real account that happens to be called `demo` stays a real account.
    public static func matches(username: String?, password: String?) -> Bool {
        username == Self.username && password == Self.password
    }

    /// The made-up library account with loans in every state a loan can be in and a charge for the overdue loan.
    ///
    /// - Parameter now: the moment the demo account is loaded, the due dates are relative to it
    /// - Returns: the demo account
    public static func account(now: Date) -> InternalAccount {
        InternalAccount(
            accountId: username,
            name: "Demo",
            address: "",
            phone: "",
            email: "",
            chargeInfo: [:],
            loans: InternalLoans(loans: loans(now: now)),
            balance: InternalBalance(total: "1,50 €", charges: charges(now: now)),
            notifications: []
        )
    }

    // MARK: Loans

    private static func loans(now: Date) -> [InternalLoan] {
        [
            loan(number: 1,
                 title: "Der Process",
                 author: "Franz Kafka",
                 signature: "DE 5 KAF",
                 dueInDays: 2,
                 borrowedDaysAgo: 26,
                 renewalsCount: 0,
                 canRenew: true,
                 now: now),
            loan(number: 2,
                 title: "Effi Briest",
                 author: "Theodor Fontane",
                 signature: "DE 5 FON",
                 dueInDays: 9,
                 borrowedDaysAgo: 47,
                 renewalsCount: 1,
                 canRenew: true,
                 now: now),
            loan(number: 3,
                 title: "Faust. Der Tragödie erster Teil",
                 author: "Johann Wolfgang von Goethe",
                 signature: "DE 5 GOE",
                 dueInDays: 0,
                 borrowedDaysAgo: 84,
                 renewalsCount: 2,
                 canRenew: false,
                 now: now),
            loan(number: 4,
                 title: "Der Schimmelreiter",
                 author: "Theodor Storm",
                 signature: "DE 5 STO",
                 dueInDays: 21,
                 borrowedDaysAgo: 7,
                 renewalsCount: 0,
                 canRenew: false,
                 lockedByPreorder: true,
                 now: now),
            loan(number: 5,
                 title: "Kinder- und Hausmärchen",
                 author: "Jacob Grimm, Wilhelm Grimm",
                 signature: "DE 3 GRI",
                 dueInDays: -3,
                 borrowedDaysAgo: 31,
                 renewalsCount: 0,
                 canRenew: false,
                 now: now),
        ]
    }

    private static func loan(number: Int,
                             title: String,
                             author: String,
                             signature: String,
                             dueInDays: Int,
                             borrowedDaysAgo: Int,
                             renewalsCount: UInt8,
                             canRenew: Bool,
                             lockedByPreorder: Bool = false,
                             now: Date) -> InternalLoan {
        let details = SearchResultDetail(
            mediumTitle: title,
            mediumAuthor: author,
            fullTitle: title,
            smallImageUrl: nil,
            signature: signature,
            dataEntries: [
                DataEntry(label: "Verfasser", value: author),
                DataEntry(label: "Medienart", value: "Buch"),
                DataEntry(label: "Standort", value: "Erwachsenenbibliothek"),
                DataEntry(label: "Signatur", value: signature),
            ],
            hint: nil,
            availability: ItemAvailability(availabilities: [])
        )

        return InternalLoan(
            title: title,
            author: author,
            canRenew: canRenew,
            renewalToken: canRenew ? "demo-renewal-token-\(number)" : nil,
            renewalsCount: renewalsCount,
            dateDue: dateString(daysFromNow: dueInDays, now: now),
            borrowedAt: dateString(daysFromNow: -borrowedDaysAgo, now: now),
            itemNumber: "\(barcodePrefix)\(String(format: "%04d", number))",
            lockedByPreorder: lockedByPreorder,
            details: details,
            searchResultDetailUrl: nil
        )
    }

    // MARK: Charges

    private static func charges(now: Date) -> [InternalCharge] {
        [
            InternalCharge(
                timestamp: Int64(Calendar.current.startOfDay(for: now).timeIntervalSince1970),
                amountOwed: 1.5,
                amountPayed: 0,
                reason: "Säumnisgebühr",
                item: "Kinder- und Hausmärchen",
                source: "Demo"
            ),
        ]
    }

    // MARK: Dates

    /// Formats a day relative to `now` the way libraries send due dates, e.g. `03.11.2026`.
    ///
    /// The formatter deliberately has the same settings as the one that reads the due dates when the loans are stored,
    /// so that a due date is read as the day it was written for.
    static func dateString(daysFromNow days: Int, now: Date) -> String {
        let date = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        return dateFormatter.string(from: date)
    }
}
