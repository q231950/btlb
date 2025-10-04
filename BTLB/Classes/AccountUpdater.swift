//
//  AccountUpdater.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 23.03.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import Foundation
import os

import Persistence
import LibraryCore
import Utilities

@objc class AccountUpdater: NSObject, AccountUpdating {

    private let dataStackProvider: DataStackProviding

    init(dataStackProvider: DataStackProviding) {
        self.dataStackProvider = dataStackProvider
    }

    @discardableResult
    func manualUpdate(in moc: NSManagedObjectContext?, at date: Date) async throws -> UpdateResult {
        let moc = moc ?? dataStackProvider.backgroundManagedObjectContext
        let accounts = try await dataStackProvider.activeAccounts(in: moc)

        do {
            return try await update(accounts, in: moc, at: date)
        } catch {
            throw PaperErrorInternal.accountUpdaterError(.manualUpdateFailed(error.localizedDescription))
        }
    }

    @discardableResult
    func update(in moc: NSManagedObjectContext?) async throws -> UpdateResult {
        let moc = moc ?? dataStackProvider.backgroundManagedObjectContext
        let accounts = try await dataStackProvider.activeAccounts(in: moc)

        return try await update(accounts, in: moc)
    }

    func update(_ account: EDAccount, completion:@escaping (NSError?) throws -> ()) {
        Task {
            do {
                _ = try await update([account.objectID], in: account.managedObjectContext)
                try completion(nil)
            } catch(let error) {
                try completion(error as NSError)
            }
        }
    }

    func update(completion:@escaping (NSError?) -> ()) {
        Task {
            do {
                _ = try await update(in: dataStackProvider.backgroundManagedObjectContext)
                completion(nil)
            } catch(let error) {
                completion(error as NSError)
            }
        }
    }

    @discardableResult
    /// Updates given accounts and publishes change events about the update
    ///
    /// - Parameters:
    ///   - accounts: the identifiers of the accounts to update
    ///   - context: the managed object context to use
    ///   - at: the moment in time of a manual update trigger.
    /// - Returns: the result of the update
    public func update(_ accounts: [NSManagedObjectID], in context: NSManagedObjectContext?, at date: Date? = nil) async throws -> UpdateResult {
        Logger.accountActivation.debug("updating account")
        guard let context = context else {
            Logger.accountActivation.debug("missing managed object context")
            Logger.accountActivation.debug("finished with error")
            throw AccountUpdaterError.missingObjectContext
        }

        return try await withThrowingTaskGroup(of: UpdateResult.self) { taskgroup in
            let changeCollection = ChangeCollection()

            for account in accounts {
                taskgroup.addTask {
                    do {
                        return try await AccountRepository(dataStackProvider: self.dataStackProvider).updateAccount(account, in: context, dataStackProvider: self.dataStackProvider)
                    } catch let error as PaperErrorInternal {
                        Logger.accountActivation.debug("finished with update error")
                        return .error(error)
                    } catch {
                        Logger.accountActivation.debug("finished with unhandled update error")
                        return .error(PaperErrorInternal.unhandledError(error.localizedDescription))
                    }
                }
            }

            for try await result in taskgroup {
                await changeCollection.collect(result)
            }

            let updateResult: UpdateResult
            // only show error in UI instead of blocking all other updates of all other accounts
            let erronousUpdateResults = await changeCollection.erronousUpdateResults
            if erronousUpdateResults.count > 0 {
                Logger.accountActivation.debug("at least one error occurred")
                UserDefaults.suite.updateErrorOccurredDate = .now
            }

            updateResult = .finished(hasChanges: await changeCollection.hasChanged, renewableItems: await changeCollection.renewableItems, returnedItems: await changeCollection.returnedItems, errors: erronousUpdateResults.reduce([]) { $0 + $1.errors })

            if updateResult.renewableItems.isEmpty {
                UserDefaults.suite.emptyRenewableItems = .now
            }

            if accounts.count >= 1 {
                Logger.accountActivation.debug("notifying about accounts' refreshed event")
                if await accounts.count == changeCollection.erronousUpdateResults.count {
                    Logger.accountActivation.debug("all accounts failed to update")
                    // all accounts failed to update
                    // schedules notifications/updates widgets
                    try await AppEventPublisher.shared.sendUpdate(.accountsRefreshed(result: .error(.accountUpdateFailed), context: context))
                } else {
                    Logger.accountActivation.debug("at least one account failed to update")
                    // schedules notifications/updates widgets
                    try await AppEventPublisher.shared.sendUpdate(.accountsRefreshed(result: updateResult, context: context))
                }
            }

            // TODO: this should be a check on the trigger (auto/manual) instead and set the date to .now
            Logger.accountActivation.debug("will set last successful update date if successful")
            if let date {
                Logger.accountActivation.debug("setting last successful update date to \(date)")
                UserDefaults.suite.latestSuccessfulManualAccountUpdateDate = date
            }


            // TODO: why does this return anything, who uses that information?
            Logger.accountActivation.debug("finished updating accounts: \(String(describing: updateResult))")
            return updateResult
        }
    }
}

extension AccountUpdater: AccountActivating {

    func activate(_ account: any Account) async -> ActivationState {
        Logger.accountActivation.debug("activate account")
        guard let account = account as? EDAccount else {
            Logger.accountActivation.debug("account is not a NSManagedObject")
            Logger.accountActivation.debug("finished activating with error")
            return .error
        }

        do {
            let result = try await update([account.objectID], in: account.managedObjectContext)

            if result.isError {
                Logger.accountActivation.debug("update error")
                Logger.accountActivation.debug("finished activating with error")
                return .error
            }

            try await account.managedObjectContext?.perform {
                Logger.accountActivation.debug("setting account properties to successful activation")
                account.activated = NSNumber(value: true)
                account.loginSuccess = NSNumber(value: true)
                try account.managedObjectContext?.save()
            }

            Logger.accountActivation.debug("finished activating with success")
            return .activated(account)
        } catch {
            Logger.accountActivation.debug("finished activating with error")
            return .error
        }
    }
}

actor ChangeCollection {
    private var changes: [UpdateResult] = []

    var erronousUpdateResults: [UpdateResult] {
        changes.filter { $0.isError }
    }

    var hasChanged: Bool {
        changes.contains { $0.hasChanges == true }
    }

    var renewableItems: [RenewableItem] {
        changes.reduce([RenewableItem]()) { partialResult, updateResult in
            partialResult + updateResult.renewableItems
        }
    }

    var returnedItems: [String] {
        changes.reduce([String]()) { partialResult, updateResult in
            partialResult + updateResult.returnedItems
        }
    }

    func collect(_ change: UpdateResult) {
        changes.append(change)
    }
}
