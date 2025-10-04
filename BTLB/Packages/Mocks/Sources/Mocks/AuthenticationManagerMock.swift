//
//  AuthenticationManagerMock.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 26.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import Foundation
import LibraryCore

public final class AuthenticationManagerMock: AuthenticationManaging {

    public var authenticated: Bool = false
    public var error: NSError? = nil

    public init() {}

    public func authenticateAccount(
        _ accountIdentifier: String,
        in library: LibraryCore.LibraryModel,
        context: NSManagedObjectContext,
        libraryProvider: any LibraryCore.LibraryProvider,
        completion: @escaping (Bool, NSError?) -> Void
    ) {
        completion(authenticated, error)
    }

    @objc public func sessionIdentifier(for accountIdentifier: String) -> String? {
        UUID().uuidString
    }
}
