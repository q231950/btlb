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


@available(iOS 17.2, *)
@AssistantIntent(schema: .system.search)
struct SearchIntent: ShowInAppSearchResultsIntent {
    static var title: LocalizedStringResource = "Search BTLB"
    static var searchScopes: [StringSearchScope] = [.general]

    @Parameter(title: "Search")
    var criteria: StringSearchCriteria

    static var description: String? {
        "Let's you search"
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let searchString = criteria.term
        print("Searching for \(searchString)")

        AppViewModel.shared.route = .openSearch

        return .result()
    }

    static var isAssistantOnly: Bool = true
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
