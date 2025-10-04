//
//  AccountRepository.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 20.08.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import CoreData
import Foundation
import os

import LibraryCore
import NetworkShim
import Persistence
import Utilities
import Libraries

@MainActor
public final class AccountRepository: AccountService {

    private let dataStackProvider: DataStackProviding

    init(dataStackProvider: DataStackProviding) {
        self.dataStackProvider = dataStackProvider
    }

    public func removeLoansNotifications() {
        Task {
            // remove all iOS notifications
            await NotificationScheduler().removeAllNotifications()

            // remove all Notification Scheduled Dates from the loans
            let moc = dataStackProvider.backgroundManagedObjectContext
            let accounts = try await dataStackProvider.persistentContainer?.accounts(in: moc)

            try await moc.perform {
                accounts?.forEach {
                    if let account = moc.object(with: $0) as? EDAccount {
                        for loan in account.allLoans {
                            loan.notificationScheduledDate = nil
                        }
                    }
                }
                try moc.save()
            }

        }
    }

    /// Update the given account.
    /// - Parameters:
    ///   - account: the account to update
    ///   - context: the NSManagedObjectContext in which the account should be modified
    /// - Returns: a ``UpdateResult``
    public func updateAccount(
        _ account: NSManagedObjectID,
        in context: NSManagedObjectContext,
        dataStackProvider: DataStackProviding
    ) async throws -> UpdateResult {
        Logger.accountRepository.debug("updateAccount \(account)")
        let databaseConnection = DatabaseConnectionFactory().databaseConnection(
            for: context,
            accountService: AccountScraper(),
            dataStackProvider: dataStackProvider
        )

        let keychainProvider = KeychainManager()
        let accountCredentialStore = AccountCredentialStore(keychainProvider: keychainProvider)

        guard let persistentContainer = dataStackProvider.persistentContainer else {
            Logger.accountRepository.debug("updateAccount missing persistent container")
            throw PaperErrorInternal.accountReposioryError(.update(.missingPersistentContainer))
        }

        let serializer = LoanSerializer(dataStackProvider: dataStackProvider)
        let loansHash = try await serializer.loansHash(for: account)

        let libraryProvider = LibraryManager(persistentContainer: persistentContainer)

        return try await initiateUpdate(accountId: account,
                                        context: context,
                                        loansHash: loansHash,
                                        libraryProvider: libraryProvider,
                                        accountCredentialStore: accountCredentialStore,
                                        databaseConnection: databaseConnection)
    }

    private func initiateUpdate(accountId: NSManagedObjectID,
                                context: NSManagedObjectContext,
                                loansHash: String,
                                libraryProvider: LibraryProvider,
                                accountCredentialStore: AccountCredentialStore,
                                databaseConnection: any LoanBackendServicing) async throws -> UpdateResult {
        Logger.accountRepository.debug("Initiating update")

        var account: EDAccount?
        var userId: String?

        await context.perform {
            account =  context.object(with: accountId) as? EDAccount
            userId = account?.accountUserID
        }

        guard let userId, let password = accountCredentialStore.password(for: userId) else {
            Logger.accountRepository.debug("initiateUpdate missing username or password 🚨")
            throw PaperErrorInternal.accountReposioryError(.update(.missingCredentials))
        }

        let serializer = LoanSerializer(dataStackProvider: dataStackProvider)
        let oldLoanBarcodes = try await serializer.loansBarcodes(for: accountId)

        try await databaseConnection.initiateUpdate(forAccount: accountId, accountIdentifier: userId, password: password, libraryProvider: libraryProvider)

        return try await updateResult(context: context,
                                      serializer: serializer,
                                      loansHash: loansHash,
                                      loanBarcodes: oldLoanBarcodes,
                                      accountId: accountId)
    }

    private func updateResult(context: NSManagedObjectContext, serializer: LoanSerializer, loansHash: String, loanBarcodes: [String], accountId: NSManagedObjectID) async throws -> UpdateResult {

        var account: EDAccount?

        await context.perform {
            account =  context.object(with: accountId) as? EDAccount
        }

        guard let account else {
            Logger.accountRepository.debug("updateResult account does not exist 🚨")
            throw PaperErrorInternal.accountReposioryError(.accountDoesNotExist)
        }

        let newLoansHash = try await serializer.loansHash(for: accountId)
        let newLoanBarcodes = try await serializer.loansBarcodes(for: accountId)

        let returnedItems = loanBarcodes.filter {
            !newLoanBarcodes.contains($0)
        }
        let updateResult: UpdateResult = .finished(hasChanges: loansHash != newLoansHash,
                                                   renewableItems: await account.renewableItems,
                                                   returnedItems: returnedItems,
                                                   errors: [])

        return updateResult
    }
}
