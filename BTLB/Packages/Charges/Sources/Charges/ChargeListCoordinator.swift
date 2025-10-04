//
//  ChargeListCoordinator.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.02.23.
//

import Combine
import Foundation
import SwiftUI

import ArchitectureX
import Localization
import Utilities

class ChargeListViewModel: ChargeListViewModelProtocol {

    private let refreshable: Refreshable

    init(refreshable: Refreshable) {
        self.refreshable = refreshable
    }

    func refresh() async throws {
        try await refreshable.refresh()
    }
}

public final class ChargeListCoordinator: Coordinator {
    public var router: Router? = Router()

    private let refreshable: Refreshable

    public init(refreshable: Refreshable) {
        self.refreshable = refreshable
    }

    public var contentView: some View {
        let viewModel = ChargeListViewModel(refreshable: refreshable)

        return ChargeListView(viewModel: viewModel)
            .navigationTitle(Localization.Titles.charges)
            .navigationBarTitleDisplayMode(.large)
    }
}
