//
//  DataStackProvider.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 31.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation
import CoreData
import LibraryCore

extension DataStackProvider: SwiftOnlyDataStackProviding {

    public func renewableItems(in context: NSManagedObjectContext) async throws -> [RenewableItem] {
        var result = [RenewableItem]()

        let accounts = try await activeAccounts(in: context)

        for managedObjectID in accounts {
            result.append(contentsOf: await items(for: managedObjectID, in: context))
        }

        return result
    }

    private func items(for accountId: NSManagedObjectID, in context: NSManagedObjectContext) async -> [RenewableItem] {
        var account: EDAccount?

        await context.perform {
            account = context.object(with: accountId) as? EDAccount
        }

        return await account?.renewableItems ?? []
    }
}

@objc public class DataStackProvider: NSObject, DataStackProviding {

    /// For performance reasons this returns mul... no, it will return a data type that collects everything the widgets and notifications need
    public func nextReturnDate(in context: NSManagedObjectContext) async -> Date? {

        do {
            let moc = context
            return try await moc.perform {
                let request = Loan.fetchRequest()

                request.sortDescriptors = [NSSortDescriptor(key: "loanExpiryDate", ascending: true)]

                let predicate = NSPredicate(format: "loanAccount.activated==1")
                request.predicate = predicate

                let loans = try moc.fetch(request)
                return loans.first?.dueDate
            }
        } catch {
            return nil
        }
    }

    public func overallNumberOfLoans(in context: NSManagedObjectContext) async -> Int {
        do {
            let moc = context
            return try await moc.perform {
                let request = Loan.fetchRequest()

                let predicate = NSPredicate(format: "loanAccount.activated==1")
                request.predicate = predicate

                let loans = try moc.fetch(request)
                return loans.count
            }
        } catch {
            return -1
        }
    }

    public func items(in context: NSManagedObjectContext, renewableOnly: Bool, fetchLimit: Int) async -> [Item] {
        do {
            let moc = context
            return try await moc.perform {
                let request = Loan.fetchRequest()

                request.sortDescriptors = [NSSortDescriptor(key: "loanExpiryDate", ascending: true),
                NSSortDescriptor(key: "loanTitle", ascending: true)]
                request.fetchLimit = fetchLimit

                request.predicate = NSPredicate(format: "loanAccount.activated==1")

                let loans = try moc.fetch(request)
                return loans.filter {
                    ($0.canRenew && renewableOnly) || !renewableOnly
                }.map {
                    Item(title: $0.title, dueDate: $0.dueDate, barcode: $0.barcode)
                }
            }
        } catch {
            return []
        }
    }

    public func accounts(in context: NSManagedObjectContext) async throws -> [NSManagedObjectID] {
        guard let persistentContainer = dataModelStack.persistentContainer else {
            throw DataStackProviderError.persistentStoreNotConfigured
        }

        return try await persistentContainer.accounts(in: context)
    }

    public func loan(for barcode: String, in context: NSManagedObjectContext) async throws -> NSManagedObjectID {
        let moc = context
        return try await moc.perform {
            let request = Loan.fetchRequest()
            
            let predicate = NSPredicate(format: "loanBarcode=='\(barcode)'")
            request.predicate = predicate
            
            let loans = try moc.fetch(request)
            guard let loan = loans.first(where: { $0.loanAccount != nil }) else {
                throw DataStackProviderError.loanNotFound
            }

            return loan.objectID
        }
    }

    public func activeAccounts(in context: NSManagedObjectContext) async throws(PaperErrorInternal) -> [NSManagedObjectID] {
        guard let persistentContainer = dataModelStack.persistentContainer else {
            throw PaperErrorInternal.dataStackProviderError(.persistentStoreNotConfigured)
        }

        do {
            return try await persistentContainer.activeAccounts(in: context)
        } catch {
            throw PaperErrorInternal.unhandledError(error.localizedDescription)
        }
    }

    @objc public static var shared: DataStackProviding = {
        DataStackProvider()
    }()

    public func createAccount() throws -> EDAccount {
        guard let persistentContainer = dataModelStack.persistentContainer else {
            throw DataStackProviderError.persistentStoreNotConfigured
        }

        return EDAccount(context: persistentContainer.viewContext)
    }

    public func newAccount() async throws -> EDAccount {
        guard let persistentContainer = dataModelStack.persistentContainer else {
            throw DataStackProviderError.persistentStoreNotConfigured
        }

        return try await persistentContainer.newAccount(context: persistentContainer.viewContext)
    }

    let dataModelStack: DataModelStack = DataModelStack()

    @objc public func load(_ completion: @escaping (() -> Void)) {
        dataModelStack.configureDefaultPersistentContainer()
        dataModelStack.loadStore(completion: completion)
    }

    public func loadInMemory() {
        dataModelStack.configurePersistentContainer(inMemory: true)
    }

    public func resetStore() {
        dataModelStack.resetStore()
    }

    @objc public var foregroundManagedObjectContext: NSManagedObjectContext {
        get {
            return dataModelStack.persistentContainer?.viewContext ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
    }

    @objc public var backgroundManagedObjectContext: NSManagedObjectContext {
        get {
            dataModelStack.persistentContainer?.newBackgroundContext() ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
    }

    @objc public var persistentContainer: PersistentContainer? {
        get {
            return dataModelStack.persistentContainer
        }
    }
}
