//
//  Item+Bookmark.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.02.23.
//

import Foundation
import LibraryCore

extension EDItem: Bookmark {

    public var bookmarkIdentifier: String? {
        identifier
    }

    public var bookmarkTitle: String? {
        title
    }

    public var bookmarkAuthor: String? {
        author
    }

    public var bookmarkImageUrl: String? {
        imageURL
    }

    public var bookmarkLibraryIdentifier: String? {
        libraryIdentifier
    }

    public var infos: [Info] {
        guard let infoPair = infoPair else { return [] }

        return infoPair.asInfos
    }
}
