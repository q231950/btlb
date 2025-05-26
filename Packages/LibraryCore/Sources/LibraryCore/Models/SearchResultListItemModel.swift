//
//  SearchResultInfoModel.swift
//  
//
//  Created by Martin Kim Dung-Pham on 15.02.22.
//

import Foundation

public struct SearchResultListItemModel {

    public let library: LibraryModel
    public let identifier: String
    public let title: String
    public let subtitle: String
    public let number: String
    public var imageUrl: URL?
    public var detailUrl: URL?

    public init(library: LibraryModel, identifier: String, title: String, subtitle: String, number: String, imageUrl: URL? = nil, detailUrl: URL? = nil) {
        self.library = library
        self.identifier = identifier
        self.title = title
        self.subtitle = subtitle
        self.number = number
        self.imageUrl = imageUrl
        self.detailUrl = detailUrl
    }
}

extension SearchResultListItemModel: Equatable {

    public static func == (lhs: SearchResultListItemModel, rhs: SearchResultListItemModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension SearchResultListItemModel: Identifiable {

    public var id: Int {
        identifier.hashValue
    }
}
