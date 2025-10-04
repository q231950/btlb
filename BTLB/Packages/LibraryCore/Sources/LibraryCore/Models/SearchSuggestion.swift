//
//  SearchSuggestion.swift
//  
//
//  Created by Martin Kim Dung-Pham on 14.02.22.
//

import Foundation

public struct SearchSuggestionModel: Identifiable, Equatable {
    public var id: String {
        searchTerm
    }

    public let searchTerm: String
    public let date: Date
    public let resultsCount: Int

    public init(searchTerm: String, date: Date, resultsCount: Int) {
        self.searchTerm = searchTerm
        self.date = date
        self.resultsCount = resultsCount
    }
}
