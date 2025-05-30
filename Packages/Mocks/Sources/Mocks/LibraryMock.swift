//
//  LibraryMock.swift
//
//
//  Created by Martin Kim Dung-Pham on 07.12.23.
//

import Foundation

import LibraryCore

public final class LibraryMock: LibraryCore.Library {
    
    public init() {}

    public var name: String? = "Library A"
    public var subtitle: String?

    public var baseURL: String?
    public var catalogUrl: String?

    public var identifier: String? = "Mock Library Identifier"

    public static func == (lhs: LibraryMock, rhs: LibraryMock) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
