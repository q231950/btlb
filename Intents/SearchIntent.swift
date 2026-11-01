//
//  SearchIntent.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 30.12.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import UIKit
import AppIntents
import Foundation

public struct SearchEntityQuery: EntityQuery {

    public init() {}

    public func entities(for identifiers: [SearchEntity.ID]) async throws -> [SearchEntity] {
        [SearchEntity(query: identifiers.first ?? "")]
    }

    /// Returns the initial results shown when a list of options backed by this query is presented.
    public func suggestedEntities() async throws -> [SearchEntity] {
        []
    }
}

public struct SearchEntity: AppEntity {

    let query: String

    init(query: String) {
        self.query = query
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource("search intent entity item display representation title \(query)"),
                              subtitle: "search intent entity item display representation subtitle")
    }

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("BTLB", table: "AppIntents")
        )
    }

    public static var defaultQuery = SearchEntityQuery()

    public var id: String {
        query
    }

}

@AppIntent(schema: .system.search)
public struct SearchIntent: ShowInAppSearchResultsIntent {
    public static var title: LocalizedStringResource = "Search BTLB"
    public static var searchScopes: [StringSearchScope] = [.general]

    @Parameter(title: "Search")
    public var criteria: StringSearchCriteria

    public init() {
    }

    @MainActor
    public func perform() async throws -> some IntentResult {
        let searchString = criteria.term
        print("Searching for \(searchString)")

        AppViewModel.shared.route = .openSearch


        return .result()
    }

    public static var openAppWhenRun: Bool { true }
    public static var isAssistantOnly: Bool = true
    public static var isDiscoverable: Bool = true
}

struct PerformSearchIntent: AppIntent {

    static var title: LocalizedStringResource = "Perform Search"

    @Parameter(title: "Search Term", description: "the term to search for")
    var query: String

    static var description = IntentDescription("perform search intent description",
                                               categoryName: "perform search intent category name",
                                               searchKeywords: [
                                                "perform search intent search keyword 1"])

    @MainActor
    func perform() async throws -> some IntentResult {

        AppViewModel.shared.route = .search(query: query)

        return .result()
    }

    static var openAppWhenRun: Bool { true }
}
