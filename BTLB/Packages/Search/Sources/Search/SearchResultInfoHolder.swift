//
//  SearchResultInfoHolder.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 14.04.17.
//  Copyright © 2017 neoneon. All rights reserved.
//

import Foundation
import Persistence
import LibraryCore

class SearchResultInfoHolder: NSObject, SearchResultInfoHolding {
    public let maxResults: NSInteger
    public let searchResultInfos: [SearchResultInfo]
    let library: any LibraryCore.Library

    required init(library: any LibraryCore.Library, maxResults: NSInteger, searchResults: [SearchResultInfo]) {
        self.library = library
        self.maxResults = maxResults
        self.searchResultInfos = searchResults
    }
}
