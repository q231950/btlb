//
//  UtilitiesDependencies.swift
//  Utilities
//
//  Created by Martin Kim Dung-Pham on 04.10.24.
//

import LibraryCore

public struct UtilitiesDependencies {
    public static var renewingUseCase: (((RenewingUseCase) async throws -> Void) async throws -> Void)?
    public static var accountValidatingUseCase: (((AccountValidatingUseCase) async throws -> ValidationStatus) async throws -> ValidationStatus)?
}
