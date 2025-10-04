//
//  ValidateAccountUseCase.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 04.10.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import os

import Paper
import LibraryCore

/// Validates an account's credentials
public struct ValidateAccountUseCase: AccountValidatingUseCase {

    private let log = OSLog(subsystem: "com.elbedev.sync", category: "\(ValidateAccountUseCase.self)")

    public init() {}

    public func validate(account: String?, password: String?, library: LibraryModel) async throws -> LibraryCore.ValidationStatus {
        guard let apiConfiguration = ApiConfiguration(library: library) else {
            throw NSError.unknownLibraryError()
        }
        let configuration = Paper.Configuration(username: account, password: password, apiConfiguration: apiConfiguration)

        let authenticator = Authenticator(configuration: configuration)
        os_log("Verifying credentials", log: self.log, type: .debug)
        let status = try await authenticator.verifyCredentials()

        return status.asValidationStatus
    }
}
