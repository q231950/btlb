//
//  APITests.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 25.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import XCTest
import CoreData

@testable import BTLB

import Libraries
import Mocks
import Persistence
import TestUtilities
import Utilities

//class APITests: XCTestCase {
//
//    let networkMock = NetworkMock()
//    let keychainMock = SomeHelper.keychainMock
//    var credentialStore: AccountCredentialStore!
//    var authManager: AuthenticationManager!
//    var mocStub: NSManagedObjectContext!
//    var account: EDAccount!
//
//    override func setUp() async throws {
//        try await super.setUp()
//        mocStub = await SomeHelper().managedObjectContextStub(for: self)
//        
//        account = try await dataStackProvider.newAccount()
//        let library = try await dataStackProvider.persistentContainer?.libraries(in: mocStub).first
//        account.library = library
//        authManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        credentialStore = AccountCredentialStore(keychainProvider: keychainMock)
//    }
//
//    func testAccountUpdateFailsWithoutPassword() async throws {
//        let api = DatabaseConnection(authenticationManager: authManager,
//                                       credentialStore: credentialStore,
//                                       context: mocStub)
//        let accountUserID = "123"
//
//        do {
//            try await api.initiateUpdate(forAccount: account.objectID, accountIdentifier: accountUserID, password: nil, libraryProvider: LibraryProviderMock(managedObjectContext: mocStub))
//        } catch(let error) {
//            if error as NSError == NSError.missingPasswordError() {
//                return
//            } else {
//                XCTFail("Wrong error thrown")
//            }
//        }
//    }
//
//    func testAccountUpdateFailsWithoutUsernameAndPassword() async throws {
//        let api = DatabaseConnection(authenticationManager: authManager,
//                                       credentialStore: credentialStore,
//                                       context: mocStub)
//        await mocStub.perform {
//            self.account.accountUserID = nil
//        }
//            let temporaryAccountIdentifier: String? = nil
//            let password: String? = nil
//            do {
//                try await api.initiateUpdate(forAccount: account.objectID,
//                                             accountIdentifier: temporaryAccountIdentifier,
//                                             password: password,
//                                             libraryProvider: LibraryProviderMock(managedObjectContext: mocStub))
//            } catch(let error) {
//                if error as NSError == NSError.missingCredentialsError() {
//                    return
//                } else {
//                    XCTFail("Wrong error thrown")
//                }
//            }
//    }
//
//    func testAccountUpdateSucceedsWithUsernameAndPassword() async throws {
//        let authenticationManager = AuthenticationManagerMock()
//        authenticationManager.authenticated = true
//
//        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)
//        let api = DatabaseConnection(authenticationManager: authenticationManager,
//                                       credentialStore: credentialStore,
//                                       context: mocStub)
//        await mocStub.perform {
//            self.account.accountUserID = "123"
//        }
//
//        try credentialStore.store("abc", of: "123")
//
//        do {
//            try await api.initiateUpdate(forAccount: account.objectID,
//                                         accountIdentifier: "",
//                                         password: "",
//                                         libraryProvider: LibraryProviderMock(managedObjectContext: mocStub))
//        } catch {
//                XCTFail("No error should be thrown")
//        }
//    }
//}
