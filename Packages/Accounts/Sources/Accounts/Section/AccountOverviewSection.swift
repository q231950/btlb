//
//  AccountOverviewSection.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 02.11.26.
//

import SwiftUI

import Charges
import LibraryUI
import Loans
import Localization
import Persistence

/// Everything that belongs to one account in a single list section: the account in the header, then its loans and its charges.
/// Tapping the header opens the editor of the account.
struct AccountOverviewSection: View {
    private let account: EDAccount
    private let editViewModel: AccountEditViewModel
    private let onLoanSelection: (Persistence.Loan) -> Void

    /// - Parameters:
    ///   - account: the account to show
    ///   - editViewModel: the view model of the account's editor, which opens when a person taps the header
    ///   - onLoanSelection: called with the loan a person taps
    init(account: EDAccount,
         editViewModel: AccountEditViewModel,
         onLoanSelection: @escaping (Persistence.Loan) -> Void) {
        self.account = account
        self.editViewModel = editViewModel
        self.onLoanSelection = onLoanSelection
    }

    var body: some View {
        Section {
            AccountLoansRows(account: account.objectID, onLoanSelection: onLoanSelection)

            AccountChargesRows(account: account.objectID)
        } header: {
            header
        }
    }

    private var header: some View {
        AccountHeaderLink(editViewModel: editViewModel) {
            ItemView(title: account.sectionTitle(.loans),
                     subtitle1: numberOfLoansText,
                     subtitle2: account.accountLibrary?.name ?? "",
                     subtitleSystemImageName: "building.columns")

            Spacer()

            AvatarView(account.avatar, size: .small)
        }
        .listRowSeparator(.hidden)
        .padding(.bottom, 10)
    }

    private var numberOfLoansText: String {
        let count = account.loans?.count ?? 0
        let itemsText = count == 1 ? "account header item" : "account header items"

        return "(\(count) \(itemsText.localized))"
    }
}
