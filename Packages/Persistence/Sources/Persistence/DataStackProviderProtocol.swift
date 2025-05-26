//
//  DataStackProvider.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 17/01/2017.
//  Copyright © 2017 neoneon. All rights reserved.
//

import CoreData
import LibraryCore

@objc public protocol DataStackProviding {
    var foregroundManagedObjectContext: NSManagedObjectContext { get }
    var backgroundManagedObjectContext: NSManagedObjectContext { get }
    var persistentContainer: PersistentContainer? { get }
    func load(_ completion: @escaping (() -> Void))
    func loadInMemory()
    func resetStore()
    @objc func newAccount() async throws -> EDAccount
    func createAccount() throws -> EDAccount
    func accounts(in context: NSManagedObjectContext) async throws -> [NSManagedObjectID]
    func loan(for barcode: String, in context: NSManagedObjectContext) async throws -> NSManagedObjectID
    func activeAccounts(in context: NSManagedObjectContext) async throws(PaperErrorInternal) -> [NSManagedObjectID]

    func nextReturnDate(in context: NSManagedObjectContext) async -> Date?
    // TODO: This would be an optional, but optional Int cannot be represented by Objc-C
    func overallNumberOfLoans(in context: NSManagedObjectContext) async -> Int
    func items(in context: NSManagedObjectContext, renewableOnly: Bool, fetchLimit: Int) async -> [Item]
}

public protocol SwiftOnlyDataStackProviding {
    func renewableItems(in context: NSManagedObjectContext) async throws -> [RenewableItem]
}
