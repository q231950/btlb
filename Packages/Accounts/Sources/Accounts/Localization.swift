//
//  Localization.swift
//  
//
//  Created by Martin Kim Dung-Pham on 01.08.23.
//

import Foundation
import SwiftUI

import Localization
import Utilities

extension Localization {
    enum List {
        public static let title: String = localized("ACCOUNTS")
        public static let newAccountButtonAccessibilityLabel: String = localized("account list new account button accessibility")
    }

    enum Detail {
        public static let title: String = localized("account detail view title")
        public static let noLibrarySelected: String = localized("account detail view library none selected")
        public static let displayNameFieldTitle: String = localized("account detail account display name field title")
        public static let usernameFieldTitle: String = localized("account detail account username field title")
        public static let passwordFieldTitle: String = localized("account detail account password field title")
        public static let activatedToggleTitle: String = localized("account detail account activated toggle title")

        public static let deleteButtonTitle: String = localized("account detail delete button title")
        public static let deleteConfirmationTitle: String = localized("account detail delete confirmation title")
        public static let deleteConfirmationOk: String = localized("account detail delete confirmed ok button title")
        public static let deleteAccountCancelButtonTitle: String = localized("account detail delete cancel button title")

        public static func specificDeleteConfirmationMessage(item name: String?) -> String {
            guard let name, name.count > 0 else {
                return localized("account detail generic delete confirmation message")
            }

            return localized("account detail specific delete confirmation message \(name)")
        }
    }

    enum EditAccount {
        enum DisplayName {
            static let title: String = localized("account edit display name title")
        }
        enum ActivateButtonTitle {
            static let activated: String = localized("account edit activate button title activated")
            static let notActivated: String = localized("account edit activate button title not activated")
            static let authenticate: String = localized("account edit activate button title authenticate")

        }
    }

    enum CreateAccount {
        enum SignIn {
            static let title: LocalizedStringKey = "account creation sign in title"
            static let librarySelectionPlaceholder: String = localized("account creation sign in library selection placeholder")
            static let usernamePlaceholder: String = localized("account creation sign in username placeholder")
            static let passwordPlaceholder: String = localized("account creation sign in password placeholder")
            static let signInButtonTitle: String = localized("account creation sign in button title")
            static let defaultAccountName: String = localized("account creation sign in default account name")
        }

        enum Error {
            static let title: String = localized("account creation error title")
            static let message: String = localized("account creation error message")
            static let dismissButtonTitle: String = localized("account creation error dismiss button title")
        }

        enum Success {
            static let title: String = localized("account creation success title")
            static let subtitle: String = localized("account creation success subtitle")
            static func message(account accountName: String) -> LocalizedStringKey {
                "account creation success message \(accountName)"
            }
            static let editButtonTitle: String = localized("account creation success edit button title")

            static func numberOfLoans(count: Int) -> LocalizedStringKey {
                "account creation success number of loans \(count)"
            }

            static let noChargesMessage: LocalizedStringKey = "account creation success no charges info message"
            static func amountOfCharges(formattedAmount: String) -> LocalizedStringKey {
                "account creation success amount of charges \(formattedAmount)"
            }

            static func numberOfDaysUntilNextExpiryDate(date: Date) -> LocalizedStringKey {
                let daysText = Localization.daysText(between: date, and: .now)

                return "account creation success number of days until next expiry date \(daysText)"
            }
            static let doneButtonTitle: String = localized("account creation success done button title")
        }
        
        enum Failure {
            static let title: String = localized("account creation failure title")
            static let dismissButtonTitle: String = localized("account creation failure dismiss button title")
            static let resetPasswordButtonTitle: String = localized("account creation failure reset password button title")
            static let failureHint1: String = localized("account creation failure hint 1")
            static let failureHint2: String = localized("account creation failure hint 2")
            static let failureHint3: String = localized("account creation failure hint 3")
            
            /// Returns a hint that mentions the exact title of the password reset button
            /// - Parameter resetButtonName: the name of the reset button
            /// - Returns: a hint to recover from sign in failure
            static func failureHint4(resetButtonName: String) -> String {
                localized("account creation failure hint 4 \(resetButtonName)")
            }
        }
    }

    static func localized(_ value: String.LocalizationValue) -> String {
        localized(value, in: .module)
    }
}
