//
//  PersistentContainer.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 05.01.19.
//  Copyright © 2019 neoneon. All rights reserved.
//

import CoreData

import LibraryCore
import Localization

public enum PersistenceBundle {
    public static var module: Bundle {
        Bundle.module
    }
}

/// The CoreData entity name
let ENTITY_NAME_ACCOUNT = "Account"

/// The CoreData entity name
let ENTITY_NAME_LIBRARY = "Library"

let DEFAULT_LIBRARY_IDENTIFIER = "Hamburg"

public class PersistentContainer: NSPersistentContainer {

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

/// Libraries
extension PersistentContainer {

    @MainActor
    public func libraries(in context: NSManagedObjectContext) throws -> [Library] {

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
    public func libraries<L>(completion: @escaping (Result<[L], Error>) -> Void) {
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
