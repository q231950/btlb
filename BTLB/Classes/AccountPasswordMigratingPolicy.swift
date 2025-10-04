//
//  AccountPasswordMigratingPolicy.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 25.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import Foundation
import Utilities

/// This entity migration policy is used in the *21to22* mapping model. It migrates the clear text password of the Account model into the keychain
/// The source Account managed object model instance (v21) still contains the password field where the new one (v22) will have that field removed.
/// To keep the users with existing passwords logged in, **a single attempt** is made to write the password into the keychain during the CoreData migration
@objc(EDAccountPasswordMigratingPolicy)
class AccountPasswordMigratingPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {

        // Store the password into the keychain if it existed in a previous account
        if let password = sInstance.value(forKey: "accountUserPassword") as? String,
            password.lengthOfBytes(using: .utf8) > 0,
            let accountIdentifier = sInstance.value(forKey: "accountUserID") as? String {
            let credentialStore = AccountCredentialStore(keychainProvider: KeychainManager())
            do {
                try credentialStore.store(password, of: accountIdentifier)
            }
        }

        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
    }
}
