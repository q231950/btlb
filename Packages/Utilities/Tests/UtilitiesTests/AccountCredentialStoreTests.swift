//
//  AccountCredentialStoreTests.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 18.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import XCTest
import TestUtilities
import Mocks
@testable import Utilities

class AccountCredentialStoreTests: XCTestCase {

    let keychainMock = SomeHelper.keychainMock
    let accountIdentifier = "a username"

    func testStoreCredentials() throws {
        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)

        // given
        let password = "123"

        // when
        try credentialStore.store(password, of: accountIdentifier)

        // then
        XCTAssertEqual(credentialStore.password(for: accountIdentifier), password)
    }

    func testRemoveCredentials() throws {
        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)

        // given
        try credentialStore.store("234", of: accountIdentifier)

        // when
        credentialStore.removePassword(for: accountIdentifier)

        // then
        XCTAssertNil(keychainMock.addedKeychainItems[accountIdentifier])
    }

    func testPrefixesAccountWithDomain() throws {
        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)

        // given
        let password = "abc"

        // when
        try credentialStore.store(password, of: accountIdentifier)

        // then
        XCTAssertEqual(keychainMock.addedKeychainItems["com.elbedev.sync.account.password.a username"], "abc")
    }

}

