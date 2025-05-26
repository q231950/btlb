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
    @FocusState private var removeFocusFromSearchBar: Bool

    @ViewBuilder var content: some View {
        switch viewModel.state {
        case .idle:
            initialSearchContent(for: viewModel)
        case .searching, .results:
            SearchResultListView(viewModel: viewModel)
        }
    }

    private var libraryName: String {
        "\(viewModel.library.name ?? "") " + "\(viewModel.library.subtitle ?? "")"
    }

    var body: some View {
        content
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Search in \(libraryName)", tableName: "Search" , bundle: .module),
                    suggestions: {
            ForEach(viewModel.suggestions) { suggestion in
                SearchSuggestionListItem(suggestion, onDelete: {
                    viewModel.deleteSuggestion(suggestion)
                })
                .searchCompletion(suggestion.searchTerm)
                .focused($removeFocusFromSearchBar)
            }
        })
        .onSubmit(of: .search) {
            viewModel.search()
            removeFocusFromSearchBar = true
        }
        .sheet(isPresented: $viewModel.isShowingLibrarySelection, content: {
            NavigationView {
                LibrarySelectionCoordinator<Persistence.Library>(for: .search, currentlySelected: viewModel.library.identifier, librarySelection: viewModel.onLibrarySelected)
                    .contentView
                    .navigationTitle(Text("LIBRARIES", tableName: "Applicationwide"))
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
            VStack {
                List {
                    Section {
                        ForEach(viewModel.suggestions) { suggestion in
                            SearchSuggestionListItem(suggestion, onSelect: {
                                removeFocusFromSearchBar = true

                                viewModel.searchText = suggestion.searchTerm

                                viewModel.search()
                            }) {
                                viewModel.deleteSuggestion(suggestion)
                            }
                            .foregroundColor(Color("textColor"))
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
