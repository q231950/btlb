//
//  LoanListViewModel.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 20.08.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

import LibraryUI
import LibraryCore
import Persistence
import Utilities

class LoanListViewModel: LibraryCore.LoanListViewModel {
    enum LoanListViewModelError: Error {
        case activationMissingAccount
        case unexpectedLoanType
    }

    var bag = Set<AnyCancellable>()
    let coordinator: LoansSectionCoordinator
    @Published var isShowingErrors: Bool = false

    private let accountUpdater: AccountUpdating
    @Published var errors: [PaperErrorInternal] = []

    init(coordinator: LoansSectionCoordinator, accountUpdater: AccountUpdating) {
        self.coordinator = coordinator
        self.accountUpdater = accountUpdater
    }

    @MainActor
    func refresh() async throws {
        do {
            let updateResult = try await accountUpdater.manualUpdate(in: DataStackProvider.shared.foregroundManagedObjectContext, at: .now)
            errors = updateResult.errors
            isShowingErrors = updateResult.errors.isEmpty == false
        } catch(let error as PaperErrorInternal) {
            print("LoanListViewModel error: \(error.localizedDescription)")
            self.errors = [error]
            isShowingErrors = true
        } catch {
            print("LoanListViewModel unhandled error: \(error.localizedDescription)")
            self.errors = [.unhandledError(error.localizedDescription)]
            isShowingErrors = true
        }
    }

    func show(_ loan: some LibraryCore.LoanViewModel) {
        let detailCoordinator = LoanCoordinator(loan: loan)

        Task { @MainActor in
            coordinator.transition(to: detailCoordinator, style: .present(modalInPresentation: false))
        }
    }
}
