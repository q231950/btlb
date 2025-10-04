//
//  DatabaseConnection+LoanService.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 16.10.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import CoreData
import Foundation

import LibraryCore
import Networking
import Persistence

public struct DatabaseConnectionDependencies {
    let accountService: AccountServiceProviding
    let authenticationManager: AuthenticationManaging
    let credentialStore: AccountCredentialStoring
    let dataStackProvider: DataStackProviding
}

public struct DatabaseConnection: LoanBackendServicing {

    private let context: NSManagedObjectContext
    private let dependencies: DatabaseConnectionDependencies

    init(context: NSManagedObjectContext, dependencies: DatabaseConnectionDependencies) {
        self.context = context
        self.dependencies = dependencies
    }

    public func initiateUpdate(forAccount accountID: NSManagedObjectID, accountIdentifier temporaryAccountIdentifier: String?, password temporaryPassword: String?, libraryProvider: Any) async throws {

        var account: Persistence.EDAccount?
        context.performAndWait {
            account = context.object(with: accountID) as? Persistence.EDAccount
        }

        if let account {
            let updateAccountDependencies: UpdateAccountDependencies = .init(
                accountCredentialStore: dependencies.credentialStore,
                accountService: dependencies.accountService
            )
            try await UpdateAccountUsecase(dependencies: updateAccountDependencies).execute(on: account)
        }
    }

    public func renew(loan: any LibraryCore.Renewable) async throws -> Result<any LibraryCore.Loan, Error> {

        let loanManagedObjectId = try await dependencies.dataStackProvider.loan(for: loan.barcode, in: context)

        guard let loan = dependencies.dataStackProvider.foregroundManagedObjectContext.object(with: loanManagedObjectId) as? Persistence.Loan, let account = loan.loanAccount else {
            assertionFailure("don't get here")
            throw RenewalError.unexpectedError
        }

        let credentialStore = dependencies.credentialStore
        guard let accountIdentifier = account.accountUserID,
              let password = credentialStore.password(for: accountIdentifier) else {
            throw NSError.missingCredentialsError()
        }

        guard let library = account.accountLibrary else {
            throw NSError.unknownLibraryError()
        }

        do {
            try await UtilitiesDependencies.renewingUseCase?() { useCase in
                let libraryModel = LibraryModel(wrapping: library)
                let (dueDateString, renewalsCount, canRenew) = try await useCase.renew(item: loan.barcode, renewalToken: loan.renewalToken, for: accountIdentifier, password: password, in: libraryModel)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                guard let dueDate = dateFormatter.date(from: dueDateString) else { return }

                loan.loanExpiryDate = dueDate;
                loan.loanCanRenew = canRenew;
                loan.loanTimesProlonged = NSNumber(value: renewalsCount)

                let item = RenewableItem(now: .now,
                                         title: loan.title,
                                         barcode: loan.barcode,
                                         canRenew: loan.canRenew,
                                         expirationDate: loan.loanExpiryDate ?? Date(),
                                         expirationNotificationDate: loan.notificationScheduledDate) { notificationTriggerDate in

                    await loan.managedObjectContext?.perform {
                        loan.notificationScheduledDate = notificationTriggerDate
                        try? loan.managedObjectContext?.save()
                    }
                }
                try await AppEventPublisher.shared.sendUpdate(.renewalSuccess(item, context: context))
            }

            return .success(loan)
        } catch let error {
            return .failure(error)
        }
    }
}
