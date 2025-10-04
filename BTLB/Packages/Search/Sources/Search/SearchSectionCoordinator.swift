//
//  SearchSectionCoordinator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import SwiftUI
import os.log

import ArchitectureX
import LibraryCore
import Utilities

public class SearchSectionCoordinator: Coordinator {

    public var router: Router? = Router()

    private let library: LibraryModel
    private let dependencies: SearchDependencies
    private lazy var viewModel: SearchSectionViewModel = {
        SearchSectionViewModel(coordinator: self, library: library, searchHistoryController: searchHistoryController, dependencies: dependencies)
    }()

    private let searchHistoryController = SearchHistoryController()

    public var contentView: some View {
        SearchSectionView(viewModel: viewModel)
    }

    public init(library: LibraryModel, dependencies: SearchDependencies) {
        self.library = library
        self.dependencies = dependencies
    }

    @MainActor
    public func prefillSearchQuery(_ query: String) {
        viewModel.searchText = query
        viewModel.search()
    }
}

extension SearchViewModel {
    convenience init(from suggestion: SearchSuggestionModel) {
        self.init(searchTerm: suggestion.searchTerm,
                  date: suggestion.date,
                  resultsCount: suggestion.resultsCount)
    }
}

extension SearchSuggestionModel {
    init(from searchViewModel: SearchViewModel) {
        self.init(searchTerm: searchViewModel.searchTerm,
                  date: searchViewModel.date,
                  resultsCount: searchViewModel.resultsCount)
    }
}

extension SearchSectionCoordinator {

    func searchStringDidChange(_ newString: String?) {

    }
}
