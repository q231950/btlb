////
////  AuthenticationManagerTest.swift
////  BTLBTests
////
////  Created by Martin Kim Dung-Pham on 08.09.18.
////  Copyright © 2018 neoneon. All rights reserved.
////
//
import XCTest
import CoreData

@testable import BTLB
import Mocks
import Persistence
//import TestUtilities
//import TestUtilitiesCore
//import Utilities
//import LibraryCore
//
//class AuthenticationManagerTest: XCTestCase {
//
//    let networkMock = NetworkMock()
//    let keychainMock = SomeHelper.keychainMock
//    var mocStub: NSManagedObjectContext!
//    var account: EDAccount!
//
//    override func setUp() async throws {
//        try await super.setUp()
//        mocStub = await SomeHelper().managedObjectContextStub(for: self)
//        account = SomeHelper.accountStub(managedObjectContext: mocStub)
//    }
//
//    func testAuthenticationRequest() throws {
//        let exp = expectation(description: "wait for async")
//        var expectedRequest = URLRequest(url: URL(string: "https://zones.buecherhallen.de/app_webuser/WebUserSvc.asmx")!)
//        expectedRequest.httpMethod = "POST"
//        expectedRequest.allHTTPHeaderFields = ["Content-Type":"text/xml; charset=utf-8",
//                                               "SOAPAction":"http://bibliomondo.com/websevices/webuser/CheckBorrower",
//                                               "Accept":"*/*",
//                                               "Accept-Language":"en-us",
//                                               "Accept-Encoding":"br, gzip, deflate"]
//        networkMock.expectRequest(expectedRequest)
//        account.accountUserID = "123"
//        try keychainMock.add(password: "abc", to: "123")
//        let authenticationManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        let libraryProvider = LibraryProviderMock(managedObjectContext: mocStub)
//        authenticationManager.authenticateAccount("123",
//                                                  libraryType: .hamburgPublic,
//                                                  accountType: "HAMBURGPUBLIC",
//                                                  context: mocStub,
//                                                  libraryProvider: libraryProvider,
//                                                  completion: { (_, _) in
//                                                    exp.fulfill()
//        })
//
//        wait(for: [exp], timeout: 0.1)
//
//        try networkMock.verifyRequests(test: self)
//    }
//
//    func testValidAuthentication() throws {
//        let exp = expectation(description: "wait for async")
//        let data = TestHelper.data(resource: "public-session-identifier-response-body", type: .xml)
//        networkMock.stub(data: data, response: nil, error: nil)
//        account.accountUserID = "123"
//        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)
//        try credentialStore.store("abc", of: "123")
//        let libraryProvider = LibraryProviderMock(managedObjectContext: mocStub)
//        let authenticationManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        authenticationManager.authenticateAccount("123", libraryType: .hamburgPublic,
//                                                  accountType: "HAMBURG",
//                                                  context: mocStub,
//                                                  libraryProvider: libraryProvider) { (authenticated, error) in
//                                                    XCTAssertTrue(authenticated)
//                                                    XCTAssertNil(error)
//                                                    exp.fulfill()
//        }
//        wait(for: [exp], timeout: 0.1)
//    }
//
//    func testInvalidAuthentication() throws {
//        let exp = expectation(description: "wait for async")
//        let data = TestHelper.data(resource: "public-incorrect-login-session-identifier-request-body", type: .xml)
//        networkMock.stub(data: data, response: nil, error: nil)
//        account.accountUserID = "123"
//        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)
//        try credentialStore.store("abc", of: "123")
//        let authenticationManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        let libraryProvider = LibraryProviderMock(managedObjectContext: mocStub)
//        authenticationManager.authenticateAccount("123", libraryType: .hamburgPublic,
//                                                  accountType: "HAMBURGPUBLIC",
//                                                  context: mocStub,
//                                                  libraryProvider: libraryProvider) { (authenticated, error) in
////                                                    XCTAssertFalse(authenticated)
//                                                    XCTAssertNil(error)
//                                                    exp.fulfill()
//        }
//        wait(for: [exp], timeout: 0.1)
//    }
//
//    func testErronousAuthentication() throws {
//        let exp = expectation(description: "wait for async")
//        let expectedError = NSError(domain: "com.elbedev.test", code: 1)
//        networkMock.stub(data: nil, response: nil, error: expectedError)
//        account.accountUserID = "123"
//        let credentialStore = AccountCredentialStore(keychainProvider: keychainMock)
//        try credentialStore.store("abc", of: "123")
//        let authenticationManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        let libraryProvider = LibraryProviderMock(managedObjectContext: mocStub)
//        authenticationManager.authenticateAccount("123", libraryType: .hamburgPublic,
//                                                  accountType: "HAMBURGPUBLIC",
//                                                  context: mocStub,
//                                                  libraryProvider: libraryProvider) { (authenticated, error) in
//                                                    //XCTAssertFalse(authenticated)
//                                                    XCTAssertEqual(error, expectedError)
//                                                    exp.fulfill()
//        }
//        wait(for: [exp], timeout: 0.1)
//    }
//
//    func testErrorWhenMissingAccountIdentifierAndPassword() {
//        let exp = expectation(description: "wait for async")
//        let authenticationManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        let libraryProvider = LibraryProviderMock(managedObjectContext: mocStub)
//        account = SomeHelper.accountStub(managedObjectContext: mocStub)
//        authenticationManager.authenticateAccount("123", libraryType: .opac,
//                                                  accountType: "HAMBURG",
//                                                  context: mocStub,
//                                                  libraryProvider: libraryProvider) { (_, error) in
//                                                    XCTAssertEqual(error, NSError.missingPasswordError())
//                                                    exp.fulfill()
//        }
//        wait(for: [exp], timeout: 0.1)
//    }
//
//    func testErrorWhenMissingPassword() {
//        let exp = expectation(description: "wait for async")
//        let libraryProvider = LibraryProviderMock(managedObjectContext: mocStub)
//        let authenticationManager = AuthenticationManager(network: networkMock, keychainManager: keychainMock)
//        account = SomeHelper.accountStub(managedObjectContext: mocStub)
//        account.accountUserID = "user id"
//
//        authenticationManager.authenticateAccount("user id",
//                                                  libraryType: .opac,
//                                                  accountType: "HAMBURG",
//                                                  context: mocStub,
//                                                  libraryProvider: libraryProvider) { (_, error) in
//            XCTAssertEqual(error, NSError.missingPasswordError())
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 0.1)
//    }
//}
//
//class LibraryProviderMock: LibraryProvider {
//    
//    var defaultLibrary: NSManagedObjectID?
//    var searchLibrary: NSManagedObjectID?
//
//    private let managedObjectContext: NSManagedObjectContext
//
//    init(managedObjectContext: NSManagedObjectContext) {
//        self.managedObjectContext = managedObjectContext
//    }
//
//    func library(forIdentifier: String, in context: NSManagedObjectContext?) -> NSManagedObjectID? {
//        var identifier: NSManagedObjectID!
//        context!.performAndWait({
//            let library = Persistence.Library(context: context!)
//            identifier = library.objectID
//        })
//
//        return identifier
//    }
//
//    func loadOrUpdateLibraries(in context: NSManagedObjectContext?) {
//
//    }
//}
//
extension SomeHelper {
    public func managedObjectContextStub(for test: XCTestCase) async -> NSManagedObjectContext {
        dataStackProvider.loadInMemory()

        return dataStackProvider.foregroundManagedObjectContext

        //        let exp = test.expectation(description: "wait for persistent store")
        //        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [PersistenceBundle.module]) else {
        //            XCTFail("Test Setup Failure: Unable to find Managed Object Model")
        //            return NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        //        }
        //
        //        let container = NSPersistentContainer(name: "BTLB Tests", managedObjectModel: managedObjectModel)
        //        let description = NSPersistentStoreDescription()
        //        description.type = NSInMemoryStoreType
        //        description.shouldAddStoreAsynchronously = true
        //        container.persistentStoreDescriptions = [description]
        //        container.loadPersistentStores { (persistentStoreDescription, error) in
        //            guard error == nil else {
        //                XCTFail("Test Setup Failure: \(error!)")
        //                return
        //            }
        //            exp.fulfill()
        //        }
        //        test.wait(for: [exp], timeout: 1.1)
        //
        //        return container.viewContext
    }
}
