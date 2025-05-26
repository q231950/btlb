//
//  AccountCredentialStore.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 18.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation
import LibraryCore

/// The Account Credential Store provides
/// a facility to store account credentials
@objc public class AccountCredentialStore: NSObject, AccountCredentialStoring {

    let keychainProvider: KeychainProvider

    /// The account credential store requires a keychain provider to store and retrieve passwords and account from.
    /// - parameter keychainProvider: The keychain provider to use
    @objc public init(keychainProvider: KeychainProvider) {
        self.keychainProvider = keychainProvider
    }

    /// Stores the given credential. Storing the credential might throw an error when the underlying keychain provider fails to add the password and username.
    /// - parameter credential: The credential to store
    @objc public func store(_ password: String, of accountIdentifier: String) throws {
        let account = "com.elbedev.sync.account.password.\(accountIdentifier)"
        try keychainProvider.add(password: password, to: account)
    }

    /// Delete a credential from the store.
    /// - parameter credential: The credential with the user identifier of the password to remove from the store
    public func removePassword(for accountIdentifier: String) {
        let account = "com.elbedev.sync.account.password.\(accountIdentifier)"
        keychainProvider.deletePassword(of: account)
    }

    /// Get the password of a user with the given user identifier
    /// - parameter accountIdentifier: The user account's identifier
    public func password(for accountIdentifier: String?) -> String? {
        guard let accountIdentifier = accountIdentifier else {
            return nil
        }
    
        let account = "com.elbedev.sync.account.password.\(accountIdentifier)"
        return keychainProvider.password(for: account)
    }
}
