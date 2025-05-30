//
//  AuthenticationManager.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 04/10/15.
//  Copyright © 2015 neoneon. All rights reserved.
//

import CoreData
import Foundation
import os

import LibraryCore
import NetworkShim
import Persistence

public class AuthenticationManager : AuthenticationManaging {

    let log = OSLog(subsystem: "com.elbedev.sync", category: "\(AuthenticationManager.self)")
    let network: any Network
    let keychainManager: KeychainProvider
    let credentialStore: AccountCredentialStore

    public required init(network: any Network, keychainManager: KeychainProvider = KeychainManager()) {
        self.network = network
        self.keychainManager = keychainManager
        self.credentialStore = AccountCredentialStore(keychainProvider: keychainManager)
    }

    public func authenticateAccount(_ accountIdentifier: String,
                                    in library: LibraryModel,
                                    context: NSManagedObjectContext,
                                    libraryProvider: LibraryCore.LibraryProvider,
                                    completion: @escaping (Bool, NSError?) -> Void) {
        guard let password = credentialStore.password(for: accountIdentifier) else {
            completion(false, NSError.missingPasswordError())
            return
        }

        authenticateAccount(accountIdentifier,
                            password: password,
                            in: library,
                            context: context,
                            libraryProvider: libraryProvider,
                            completion: completion)
    }

    public func authenticateAccount(_ accountIdentifier: String,
                                    password: String,
                                    in library: LibraryModel?,
                                    context: NSManagedObjectContext,
                                    libraryProvider: LibraryCore.LibraryProvider,
                                    completion: @escaping (Bool, NSError?) -> Void) {
        guard let library = library else {
            completion(false, NSError.unknownLibraryError())
            return
        }

        Task {
            do {
                let result = try await self.authenticateAccount(accountIdentifier:accountIdentifier, password: password, in: library)
                context.performAndWait {
                    completion(result, nil)
                }
            } catch {
                context.performAndWait {
                    completion(false, NSError(domain: "Authentication", code: 1, userInfo: ["error": error]))
                }
            }
        }
    }

    /**
     Retrieve a session identifier for a belonging account
     - returns: The optional session identifier if one was found
     - parameter accountIdentifier: The identifier of the belonging account
     */
    public func sessionIdentifier(for accountIdentifier: String) -> String? {
        let account = "com.elbedev.sync.session.account.\(accountIdentifier)"
        return keychainManager.password(for: account)
    }

    /**
     Store a session identifier for an account
     Parameters:
     - parameter identifier: The session identifier to store
     - parameter accountIdentifier: The identifier of the belonging account
     */
    private func store(sessionIdentifier identifier: String, for accountIdentifier: String) throws {
        let account = "com.elbedev.sync.session.account.\(accountIdentifier)"
        try keychainManager.add(password:identifier, to:account)
    }
    
    private func authenticateAccount(accountIdentifier: String, password: String, in library: LibraryModel) async throws -> Bool {
        switch await validate(accountIdentifier, password: password, in: library) {
        case .valid:
            true
        case .invalid:
            false
        case .error(let err):
            throw NSError(domain: "com.elbedev.sync", code: 1, userInfo: [NSLocalizedDescriptionKey : err])
        case .none:
            throw NSError.authenticationError()
        }
    }
    
    private func validate(_ accountIdentifier: String, password: String, in library: LibraryModel) async -> ValidationStatus? {
        do {
            return try await UtilitiesDependencies.accountValidatingUseCase? { useCase in
                try await useCase.validate(account: accountIdentifier, password: password, library: library) // initialize the authentication manager with a library
            }
        } catch {
            os_log("Failed to sign in", log: self.log, type: .debug, error.localizedDescription as CVarArg)
            return .error(error.localizedDescription)
        }
    }
}
