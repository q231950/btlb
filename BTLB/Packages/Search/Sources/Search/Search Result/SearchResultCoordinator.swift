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

import Persistence

class SearchResultCoordinator: Coordinator {

    var router: Router?
    private let result: SearchResultListItemModel
    private let detailsProvider: SearchResultDetailsProviding
    private let dataStackProvider: DataStackProviding

    init(result: SearchResultListItemModel, detailsProvider: SearchResultDetailsProviding, dataStackProvider: DataStackProviding) {
        self.result = result
        self.detailsProvider = detailsProvider
        self.dataStackProvider = dataStackProvider
    }

    var contentView: some View {
        SearchResultDetailView(viewModel: SearchResultInfoViewModel(coordinator: self, result: result, detailsProvider: detailsProvider, dataStackProvider: dataStackProvider))
    }
}
