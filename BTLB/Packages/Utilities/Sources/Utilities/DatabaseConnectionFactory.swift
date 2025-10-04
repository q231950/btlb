//
//  DatabaseConnectionFactory.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 04.03.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import CoreData
import Foundation

import LibraryCore
import Networking
import Persistence

public protocol DatabaseConnectionProducing {
    func databaseConnection(
        for managedObjectContext: NSManagedObjectContext,
        accountService: AccountServiceProviding,
        dataStackProvider: DataStackProviding
    ) -> LoanBackendServicing
}

public struct DatabaseConnectionFactory: DatabaseConnectionProducing {

    public init() {}

    public func databaseConnection(
        for managedObjectContext: NSManagedObjectContext,
        accountService: AccountServiceProviding,
        dataStackProvider: DataStackProviding
    ) -> LoanBackendServicing {
        let keychainProvider = KeychainManager()
        let authenticationManager = AuthenticationManager(network: NetworkClient(), keychainManager: keychainProvider)
        let accountCredentialStore = AccountCredentialStore(keychainProvider: keychainProvider)

        return DatabaseConnection(
            context: managedObjectContext,
            dependencies: DatabaseConnectionDependencies(
                accountService: accountService,
                authenticationManager: authenticationManager,
                credentialStore: accountCredentialStore,
                dataStackProvider: dataStackProvider
            )
        )
    }
}
