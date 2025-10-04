//
//  BookmarkListViewModel.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 15.02.23.
//  Copyright © 2023 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

import ArchitectureX
import LibraryCore

@MainActor public class BookmarkListViewModel: @MainActor Bookmarks.BookmarkListViewModelProtocol {

    @Published public var searchText: String = ""
    private var currentDetailCoordinator: (any Coordinator)?

    public init(currentDetailCoordinator: (any Coordinator)? = nil) {
        self.searchText = searchText
        self.currentDetailCoordinator = currentDetailCoordinator
    }

    public func show(_ bookmark: any LibraryCore.Bookmark, coordinator: any Coordinator) {
        let detailCoordinator = BookmarkCoordinator(bookmark: bookmark)
        currentDetailCoordinator = detailCoordinator

        Task { @MainActor in
            coordinator.transition(to: detailCoordinator, style: .present(modalInPresentation: false))
        }
    }

    public func onRecommendationButtonTap(coordinator: BookmarkListCoordinator<some BookmarkListViewModelProtocol>, bookmarks: [any LibraryCore.Bookmark]) {
        coordinator.startRecommendationFlow(with: bookmarks)
    }
}
