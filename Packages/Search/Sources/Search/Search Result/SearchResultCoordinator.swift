//
//  SearchResultCoordinator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import SwiftUI
import ArchitectureX
import LibraryCore

class SearchResultCoordinator: Coordinator {

    var router: Router?
    private let result: SearchResultListItemModel
    private let detailsProvider: SearchResultDetailsProviding

    init(result: SearchResultListItemModel, detailsProvider: SearchResultDetailsProviding) {
        self.result = result
        self.detailsProvider = detailsProvider
    }

    var contentView: some View {
        SearchResultDetailView(viewModel: SearchResultInfoViewModel(coordinator: self, result: result, detailsProvider: detailsProvider))
    }
}
