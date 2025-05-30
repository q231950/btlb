//
//  LocalAccountRepository.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.08.23.
//

import CoreData
import Foundation
import LibraryCore

public struct LocalAccountRepository: LocalAccountService {
    private let context: NSManagedObjectContext

    public func account(for identifier: NSManagedObjectID, in context: NSManagedObjectContext) async -> Account? {
        await context.perform {
            context.object(with: identifier) as? EDAccount
        }
    }

    public func deleteAccount(with identifier: NSManagedObjectID) async throws {
        try await context.perform {
            context.delete(context.object(with: identifier))

            try context.save()
        }

        try await AppEventPublisher.shared.sendUpdate(
            .accountsRefreshed(result: .finished(
                hasChanges: true,
                renewableItems: [],
                returnedItems: [],
                errors: []
            ),

                               context: context
            )
        )
    }

    public init(context: NSManagedObjectContext) {
        self.context = context
    }
}
