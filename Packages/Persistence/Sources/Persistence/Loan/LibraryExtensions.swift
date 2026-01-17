//
//  File.swift
//  
//
//  Created by Martin Kim Dung-Pham on 03.04.24.
//

import Foundation

import CoreData
import LibraryCore

public extension LibraryModel {
    init?(wrapping: Persistence.Library?) {
        guard let wrapping else { return nil }
        self.init(
            name: wrapping.name,
            subtitle: wrapping.subtitle,
            identifier: wrapping.identifier,
            enabledForSearch: wrapping.enabledForSearch,
            enabledForLogin: wrapping.enabledForLogin
        )
    }
}
