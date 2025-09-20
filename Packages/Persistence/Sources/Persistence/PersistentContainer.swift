//
//  PersistentContainer.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 05.01.19.
//  Copyright © 2019 neoneon. All rights reserved.
//

import CoreData
import SwiftUI

import LibraryCore
import Localization

public enum PersistenceBundle {
    public static var module: Bundle {
        Bundle.module
    }
}

public extension EnvironmentValues {
    var dataStackProvider: DataStackProviding {
        get { self[DataStackProviderEnvironmentKey.self] }
        set { self[DataStackProviderEnvironmentKey.self] = newValue }
    }
}

public struct DataStackProviderEnvironmentKey: EnvironmentKey {
    public static var defaultValue: DataStackProviding = NoOpDataStackProvider()
}

class NoOpDataStackProvider: DataStackProviding {
    var foregroundManagedObjectContext: NSManagedObjectContext {
        fatalError()
    }

    var backgroundManagedObjectContext: NSManagedObjectContext {
        fatalError()
    }

    var persistentContainer: PersistentContainer?
    
    func load(_ completion: @escaping () -> Void) {
    }
    
    func loadInMemory() {
    }
    
    func resetStore() {
    }
    
    func newAccount() async throws -> EDAccount {
        fatalError()
    }
    
    func createAccount() throws -> EDAccount {
        fatalError()
    }
    
    func accounts(in context: NSManagedObjectContext) async throws -> [NSManagedObjectID] {
        fatalError()
    }
    
    func loan(for barcode: String, in context: NSManagedObjectContext) async throws -> NSManagedObjectID {
        fatalError()
    }
    
    func activeAccounts(in context: NSManagedObjectContext) async throws(LibraryCore.PaperErrorInternal) -> [NSManagedObjectID] {
        fatalError()
    }
    
    func nextReturnDate(in context: NSManagedObjectContext) async -> Date? {
        fatalError()
    }
    
    func overallNumberOfLoans(in context: NSManagedObjectContext) async -> Int {
        fatalError()
    }
    
    func items(in context: NSManagedObjectContext, renewableOnly: Bool, fetchLimit: Int) async -> [LibraryCore.Item] {
        fatalError()
    }
    
    
}

//public extension EnvironmentValues {
//    var persistentContainer: PersistentContainer? {
//        get { self[PersistentContainerEnvironmentKey.self] }
//        set { self[PersistentContainerEnvironmentKey.self] = newValue }
//    }
//}
//
//public struct PersistentContainerEnvironmentKey: EnvironmentKey {
//    public static var defaultValue: PersistentContainer? = nil
//}

/// The CoreData entity name
let ENTITY_NAME_ACCOUNT = "Account"

/// The CoreData entity name
let ENTITY_NAME_LIBRARY = "Library"

let DEFAULT_LIBRARY_IDENTIFIER = "Hamburg"

public class PersistentContainer: NSPersistentContainer, @unchecked Sendable {

    func newAccount(context: NSManagedObjectContext) async throws -> EDAccount {
        var result: EDAccount!
            let libraries = try await self.libraries(in: context)
        await context.perform {
            let account = EDAccount(context: context)

            account.accountCreationDate = Date()
            // TODO: Fix default account name
            account.accountName = "account name placeholder".localized(bundle: .localization)
            account.accountType = "HAMBURGPUBLIC"

            if let library = libraries.first(where: { $0.identifier == account.accountType }) {
                account.accountTypeName = library.name
                account.accountLibrary = library
                account.loginSuccess = false
            }

            do {
                try context.save()
            } catch {
                
            }
            result = account
        }

        return result
    }
}

extension PersistentContainer {

    public func activeAccounts(in context: NSManagedObjectContext) async throws -> [NSManagedObjectID] {
        try await viewContext.perform {
            let request = EDAccount.fetchRequest()

            request.sortDescriptors = [NSSortDescriptor(key: "accountName", ascending: true)]

            let predicate = NSPredicate(format: "self.activated==1")
            request.predicate = predicate

            return try self.viewContext.fetch(request).map { $0.objectID }
        }
    }

    public func accounts(in context: NSManagedObjectContext) async throws -> [NSManagedObjectID] {
        try await viewContext.perform {
            let request = EDAccount.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "accountName", ascending: true)]

            do {
                let objects = try self.viewContext.fetch(request).map { $0.objectID }
                return objects
            }
        }
    }


}

// MARK: - Libraries

public extension PersistentContainer {

    @MainActor
    func libraries(in context: NSManagedObjectContext) throws -> [Library] {

        let fetchRequest = NSFetchRequest<Library>(entityName: ENTITY_NAME_LIBRARY)

        let predicate = NSPredicate(format: "self.identifier != %@ AND self.name != ''", argumentArray: [DEFAULT_LIBRARY_IDENTIFIER])
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        return try context.fetch(fetchRequest)
    }

    /**
     Get the libraries

     - Returns: An array containing all Library objects except the default library

     - Parameter completion: The completion with a result
     */
    func libraries<L>(completion: @escaping (Result<[L], Error>) -> Void) {
        let fetchRequest = NSFetchRequest<Library>(entityName: ENTITY_NAME_LIBRARY)

        let predicate = NSPredicate(format: "self.identifier != %@ AND self.name != ''", argumentArray: [DEFAULT_LIBRARY_IDENTIFIER])
        fetchRequest.predicate = predicate

        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        viewContext.perform {
            do {
                let result = try self.viewContext.fetch(fetchRequest) as? [L] ?? []
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
