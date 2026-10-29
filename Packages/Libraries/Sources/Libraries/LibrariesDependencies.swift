//
//  LibrariesDependencies.swift
//  Libraries
//
//  Created by Martin Kim Dung-Pham on 16.01.26.
//


import LibraryCore

public struct LibrariesDependencies {
    public static var libraryModelProvider: (
        ((LibraryModelProvider) async throws -> Void) async throws -> Void
    )?
}
