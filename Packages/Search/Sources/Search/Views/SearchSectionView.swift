//
//  SearchSectionView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 09.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

import ArchitectureX
import Libraries
import LibraryCore
import LibraryUI
import Persistence

struct SearchSectionView: View {

    @ObservedObject var viewModel: SearchSectionViewModel
    @FocusState private var isSearchFieldFocused: Bool
    @Environment(\.dataStackProvider) private var dataStackProvider

    @ViewBuilder var content: some View {
        switch viewModel.state {
        case .idle:
            initialSearchContent(for: viewModel)
        case .searching, .results:
            SearchResultListView(viewModel: viewModel)
                .overlay {
                    // While the search text is being edited, the search history covers the results, so
                    // the results keep their scroll position for when editing ends.
                    if isSearchFieldFocused && !viewModel.suggestions.isEmpty {
                        searchHistory
                            .background(.background)
                    }
                }
        }
    }

    private var libraryName: String {
        "\(viewModel.library.name ?? "") " + "\(viewModel.library.subtitle ?? "")"
    }

    var body: some View {
        content
        // Automatic placement lets the field live in the iOS 26 search tab at the bottom of the screen.
        //
        // The search history is shown in this view's own list instead of as search suggestions. SwiftUI
        // presents suggestions in a list of its own, and the search field above the keyboard covers the
        // end of that list once it scrolls.
        .searchable(text: $viewModel.searchText,
                    prompt: Text("Search in \(libraryName)", tableName: "Search" , bundle: .module))
        .searchFocused($isSearchFieldFocused)
        .onSubmit(of: .search) {
            viewModel.search()
            isSearchFieldFocused = false
        }
        .sheet(isPresented: $viewModel.isShowingLibrarySelection, content: {
            NavigationView {
                LibrarySelectionCoordinator<Persistence.Library>(
                    for: .search,
                    persistentContainer: dataStackProvider.persistentContainer,
                    currentlySelected: viewModel.library.identifier,
                    librarySelection: viewModel.onLibrarySelected
                )
                .contentView
                .navigationTitle(Text("Libraries", tableName: "Search", bundle: .module))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            Task {
                                viewModel.isShowingLibrarySelection = false
                            }
                        }) {
                            Text("CANCEL", tableName: "Applicationwide")
                        }
                    }
                }
            }
        })
        .alert(
            "Technical Error",
            isPresented: $viewModel.showsTechnicalError,
            actions: {
                Button("OK") {}
            },
            message: {
                Text("Search failed in this library (\(viewModel.technicalError ?? "n/a").")
            }
        )
        .alert(
            "Unsupported Library",
            isPresented: $viewModel.showsLibrarySupportHint,
            actions: {
                Button("OK") {}
            },
            message: {
                Text("The selected library is not supported by this app at this moment. Please select a supported library.")
            }
        )
        .toolbar {
            Button {
                viewModel.isShowingLibrarySelection = true
            } label: {
                Image(systemName: "building.columns.circle")
            }
            .accessibilityLabel(Text("Set_Search_Catalogue", tableName: "Accessibles"))
        }
        .navigationTitle(Text("SEARCH", tableName: "Search", bundle: .module))
    }

    @ViewBuilder private func initialSearchContent(for viewModel: SearchSectionViewModel) -> some View {
        if viewModel.previousSearchCount == 0 {
            ScrollView {
                Text("Welcome to search", tableName: "Search", bundle: .module)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        } else {
            searchHistory
        }
    }

    /// The previous searches that match the search text.
    private var searchHistory: some View {
        List {
            Section {
                ForEach(viewModel.suggestions) { suggestion in
                    SearchSuggestionListItem(suggestion, onSelect: {
                        isSearchFieldFocused = false

                        viewModel.searchText = suggestion.searchTerm

                        viewModel.search()
                    }) {
                        viewModel.deleteSuggestion(suggestion)
                    }
                    .foregroundColor(Color("textColor"))
                }
            }
        }
        .listStyle(.plain)
    }
}
