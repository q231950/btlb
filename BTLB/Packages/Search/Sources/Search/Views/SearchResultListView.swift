//
//  SearchResultListView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 10.04.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import SwiftUI
import LibraryUI

struct SearchResultListView: View {

    @ObservedObject var viewModel: SearchSectionViewModel

    var body: some View {
        List {
            Section(header: Text("Number of results: \(viewModel.currentSearchResultList?.maxResults ?? 0)", tableName: "Search", bundle: .module)
                    // filter options? 😲
//                        HStack {
//                Text("Number of results: \(viewModel.currentSearchResultList?.maxResults ?? 0)")
//    Spacer()
//                Image(systemName: "slider.vertical.3")
//                }
            ) {
                ForEach(viewModel.searchResults, id: \.identifier) { result in
                    SearchResultListItemView(result: result) {
                        viewModel.show(result: $0)
                    }
                    .listRowSeparator(.hidden)
                    .onAppear {
                        Task {
                            try await viewModel.loadMoreResultsIfNeeded(after: result)
                        }
                    }
                }

                if viewModel.state == .searching {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .id(UUID()) // Forces view update
                }
            }
        }
        .listSectionSeparator(.hidden)
        .listStyle(.plain)
    }
}
