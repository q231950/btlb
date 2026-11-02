//
//  AccountsSectionViewModel.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 02.11.26.
//

import Foundation

import LibraryCore

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
}
