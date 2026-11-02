//
//  AccountsSectionCoordinator.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 02.11.26.
//

import SwiftUI

import ArchitectureX
import LibraryCore
import Loans

/// Shows every account with its loans and charges in a single list, and presents the details of a loan a person taps.
@MainActor public class AccountsSectionCoordinator: @MainActor Coordinator {
    public var router: Router? = Router()

    private let updateAccounts: @MainActor () async throws -> UpdateResult

    private lazy var viewModel = AccountsSectionViewModel(updateAccounts: updateAccounts) { [weak self] loan, loanService in
        self?.showDetails(of: loan, loanService: loanService)
    }

    /// - Parameter updateAccounts: updates all active accounts from their libraries, for example when a person pulls to refresh
    public init(updateAccounts: @escaping @MainActor () async throws -> UpdateResult) {
        self.updateAccounts = updateAccounts
    }

    public var contentView: some View {
        AccountsSectionView(viewModel: viewModel)
    }

    private func showDetails(of loan: any LibraryCore.Loan, loanService: any LoanService) {
        let detailCoordinator = LoanDetailCoordinator(loan: loan, loanService: loanService)

        transition(to: detailCoordinator, style: .present(modalInPresentation: false))
    }
}
