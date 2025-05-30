//
//  SearchDependencies.swift
//  Search
//
//  Created by Martin Kim Dung-Pham on 28.12.24.
//

import Foundation

import Utilities
import LibraryCore

public class SearchDependencies {
    let databaseConnection: DatabaseConnection?
    let searchProvider: any SearchScraping
    let detailsProvider: any SearchResultDetailsProviding

    public init(databaseConnection: DatabaseConnection?, searchProvider: any SearchScraping, detailsProvider: any SearchResultDetailsProviding) {
        self.databaseConnection = databaseConnection
        self.searchProvider = searchProvider
        self.detailsProvider = detailsProvider
    }
}
