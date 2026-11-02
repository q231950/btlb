//
//  AccountsSectionViewModel.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 02.11.26.
//

import CoreData
import Foundation

import LibraryCore
import Persistence

@MainActor final class AccountsSectionViewModel: ObservableObject {
    @Published var isShowingErrors = false
    @Published private(set) var errors: [PaperErrorInternal] = []

    private let updateAccounts: @MainActor () async throws -> UpdateResult
    private let onLoanSelection: @MainActor (any LibraryCore.Loan, any LoanService) -> Void

    /// - Parameters:
    ///   - updateAccounts: updates all active accounts from their libraries
    ///   - onLoanSelection: shows the details of a loan, renewed and bookmarked with the given loan service
    init(updateAccounts: @escaping @MainActor () async throws -> UpdateResult,
         onLoanSelection: @escaping @MainActor (any LibraryCore.Loan, any LoanService) -> Void) {
        self.updateAccounts = updateAccounts
        self.onLoanSelection = onLoanSelection
    }

    /// Updates all accounts and keeps the errors of the update, so they can be shown.
    func refresh() async {
        do {
            let updateResult = try await updateAccounts()
            errors = updateResult.errors
        } catch let error as PaperErrorInternal {
            errors = [error]
        } catch {
            errors = [.unhandledError(error.localizedDescription)]
        }

        isShowingErrors = !errors.isEmpty
    }

    func show(_ loan: any LibraryCore.Loan, loanService: any LoanService) {
        onLoanSelection(loan, loanService)
    }

    /// Creates the view model of the editor of an account.
    ///
    /// View models of the same account are equal, so a person stays in the editor while the list behind it updates.
    /// - Parameters:
    ///   - account: the identifier of the account to edit
    ///   - dataStackProvider: provides the context the account is edited in
    ///   - accountService: loads and deletes the account
    ///   - accountCredentialStore: holds the password of the account
    ///   - accountActivating: activates the account after a person signed in
    func accountEditViewModel(for account: NSManagedObjectID,
                              dataStackProvider: DataStackProviding,
                              accountService: LocalAccountService,
                              accountCredentialStore: AccountCredentialStoring,
                              accountActivating: AccountActivating) -> AccountEditViewModel {
        AccountEditViewModel(accountService: accountService,
                             accountCredentialStore: accountCredentialStore,
                             accountActivating: accountActivating,
                             managedObjectContext: dataStackProvider.foregroundManagedObjectContext,
                             managedObjectId: account,
                             dataStackProvider: dataStackProvider)
    }
}
