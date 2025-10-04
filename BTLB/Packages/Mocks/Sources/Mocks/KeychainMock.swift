//
//  KeychainMock.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 09.09.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import Foundation
//import XCTest

import LibraryCore
import Persistence

public protocol TestableKeychainProvider: KeychainProvider {
    var addedKeychainItems:[String:String] { get }
}

public class KeychainMock: TestableKeychainProvider {

    public init() {}

    public var addedKeychainItems = [String:String]()

    public func add(password: String, to account: String) throws {
        addedKeychainItems[account] = password
    }

    public func password(for account: String) -> String? {
        return addedKeychainItems[account]
    }

    public func deletePassword(of account: String) {
        addedKeychainItems.removeValue(forKey: account)
    }
}

public struct SomeHelper {

    public init() {}

    public static var keychainMock: TestableKeychainProvider {
        KeychainMock()
    }
    
    public static func accountStub(managedObjectContext: NSManagedObjectContext) -> EDAccount {
        var result: EDAccount!

        managedObjectContext.performAndWait {
            let account = EDAccount(context: managedObjectContext)
            let library = Persistence.Library(context: managedObjectContext)
            library.type = 1
            account.accountLibrary = library

            result = account
        }

        return result
    }

}
