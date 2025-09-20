//
//  SearchSectionViewModel.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import os.log
import ArchitectureX
import LibraryCore
import Persistence
import Utilities

class SearchSectionViewModel: ObservableObject {

    enum State {
        case idle, searching, results
    }

    @Published var library: LibraryModel
    @Published var showsLibrarySupportHint = false
    @Published var showsTechnicalError = false
    var technicalError: String? {
        didSet {
            showsTechnicalError = technicalError != nil
        }
    }
    @Published var searchText: String = "" {
        didSet {
            Task {
                await suggest(for: searchText)
            }
        }
    }
    @Published var suggestions: [SearchSuggestionModel]
    @Published var previousSearchCount: Int
    @Published var searchResults = [SearchResultListItemModel]()
    @Published var state: State = .idle
    @Published var isShowingLibrarySelection = false

    let coordinator: SearchSectionCoordinator
    private let dependencies: SearchDependencies
    private let searchHistoryController: SearchHistoryController
    var currentSearchResultList: SearchResultList?

    init(coordinator: SearchSectionCoordinator, library: LibraryModel, searchHistoryController: SearchHistoryController, dependencies: SearchDependencies) {
        self.coordinator = coordinator
        self.library = library
        self.dependencies = dependencies
        self.searchHistoryController = searchHistoryController
        self.suggestions = searchHistoryController.searches.map({ SearchSuggestionModel(from: $0) })
        self.previousSearchCount = searchHistoryController.searches.count
        searchHistoryController.delegate = self
    }

    @MainActor func search() {
        guard library.isAvailable else {
            showsLibrarySupportHint = true
            return
        }
        searchResults.removeAll()

        state = .searching

        Task {
            do {
                try await self.search(for: self.searchText)

                self.state = .results
            } catch {
                self.technicalError = error.localizedDescription
                state = .idle
            }
        }
    }

    @MainActor func suggest(for text: String) {
        Logger.search.info("[SearchSectionCoordinator] Suggest for: \(text)")

        if text.count == 0 {
            suggestions = searchHistoryController.searches.map({ SearchSuggestionModel(from: $0) })
        } else {
            suggestions = searchHistoryController.searches
                .filter({ $0.searchTerm.lowercased().contains(text.lowercased()) })
                .map({ SearchSuggestionModel(from: $0) })
        }
    }

    @MainActor func deleteSuggestion(_ suggestion: SearchSuggestionModel) {
        suggestions.removeAll(where: { $0 == suggestion })
        searchHistoryController.delete(SearchViewModel(from: suggestion))
    }

    @MainActor func search(for text: String) async throws {
        Logger.search.info("[SearchSectionCoordinator] Search for: \(text)")

        currentSearchResultList = try await dependencies.searchProvider.search(text: text, in: library, nextPageUrl: nil)
        searchHistoryController.updateSearchHistory(searchText: text, resultCount: currentSearchResultList?.maxResults ?? 0)

        Logger.search.info("[SearchSectionCoordinator] Done searching")

        await addSearchResultInfos((currentSearchResultList?.items ?? []))
    }

    @MainActor func loadMoreResultsIfNeeded(after result: SearchResultListItemModel) async throws {
        guard state != .searching else {
            Logger.search.info("[SearchSectionCoordinator] Not loading more, already in progress")
            return }

        Logger.search.info("[SearchSectionCoordinator] Attempt to load more search results")
        guard let nextPageUrl = currentSearchResultList?.nextPageUrl, searchResults.count < currentSearchResultList?.maxResults ?? Int.max else { return }

        let thresholdIndex = searchResults.index(searchResults.endIndex, offsetBy: -5)
        if searchResults.firstIndex(where: { $0.id == result.id }) == thresholdIndex {

            state = .searching
            Logger.search.info("[SearchSectionCoordinator] Loading more")

            currentSearchResultList = try await dependencies.searchProvider.search(
                text: currentSearchResultList?.text ?? "",
                in: library,
                nextPageUrl: nextPageUrl
            )

            await addSearchResultInfos((currentSearchResultList?.items ?? []))
            Logger.search.info("[SearchSectionCoordinator] Done loading more")
            state = .results
        }
    }

    @MainActor
    func addSearchResultInfos(_ viewModels: [SearchResultListItem]) async {
        searchResults.append(contentsOf: viewModels.compactMap {
            let library = LibraryModel(name: library.name ?? "",
                                       subtitle: library.subtitle ?? "",
                                       identifier: library.identifier ?? "",
                                       baseUrl: library.baseURL,
                                       catalogUrl: library.catalogUrl)
            return SearchResultListItemModel(library: library,
                                         identifier: $0.identifier,
                                         title: $0.title ?? "",
                                         subtitle: $0.subtitle ?? "",
                                             number: $0.itemNumber ?? "",
                                             imageUrl: URL(string: $0.coverImageUrl ?? ""),
                                             detailUrl: URL(string: $0.detailUrl ?? ""))
        })
    }

    @MainActor func show(result: SearchResultListItemModel) {
        let detailCoordinator = SearchResultCoordinator(result: result, detailsProvider: dependencies.detailsProvider, dataStackProvider: dependencies.dataStackProvider)

        coordinator.transition(to: detailCoordinator, style: .present(modalInPresentation: false))
    }

    @MainActor func onLibrarySelected(selectedLibrary: Persistence.Library) {
        library = LibraryModel(name: selectedLibrary.name ?? "unknown",
                               subtitle: selectedLibrary.subtitle ?? "unknown",
                               identifier: selectedLibrary.identifier ?? "unknown",
                               baseUrl: selectedLibrary.baseURL,
                               catalogUrl: selectedLibrary.catalogUrl)

//        coordinator.selectedLibrary = library.identifier
        UserDefaults.standard.set(selectedLibrary.identifier, forKey: "search_Library")
        isShowingLibrarySelection = false
    }
}

extension SearchSectionViewModel: SearchHistoryControllerDelegate {

    func searchHistoryDidChange(recentSearches: [SearchViewModel]) {
        previousSearchCount = searchHistoryController.searches.count
    }

    func searchHistoryDidDelete(_ searchViewModel: SearchViewModel) {
        previousSearchCount = searchHistoryController.searches.count
        state = .idle
    }
}

extension LibraryCore.Availability: @retroactive Identifiable {
    public var id: Int {
        switch self {
        case .available(let location): return location.hashValue
        case .notAvailable(let location): return location.hashValue
        case .unknown(let location): return location.hashValue
        }
    }
}
