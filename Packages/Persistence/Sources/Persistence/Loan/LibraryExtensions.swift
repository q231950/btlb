//
//  File.swift
//  
//
//  Created by Martin Kim Dung-Pham on 03.04.24.
//

import Foundation

import CoreData
import LibraryCore

extension Persistence.Library {
    public var libraryType: LibraryCore.LibraryType {
        LibraryType(rawValue: type?.intValue ?? 0) ?? .hamburgPublic
    }

    public var catalogUrl: String? {
        catalogueBaseString
    }
}

public extension LibraryModel {
    init?(wrapping: Persistence.Library?) {
        guard let wrapping else { return nil }
        self.init(
            name: wrapping.name,
            subtitle: wrapping.subtitle,
            identifier: wrapping.identifier,
            baseUrl: wrapping.baseURL,
            catalogUrl: wrapping.catalogUrl
        )
    }
}
