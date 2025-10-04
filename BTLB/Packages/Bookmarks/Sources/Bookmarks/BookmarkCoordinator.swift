//
//  BookmarkCoordinator.swift
//  
//
//  Created by Martin Kim Dung-Pham on 16.02.23.
//

import Combine
import CoreData
import SwiftUI

import ArchitectureX

import LibraryCore
import Localization
import Persistence
import Utilities

@MainActor public class BookmarkCoordinator: @MainActor Coordinator {
    public var router: Router?

    private var bookmark: any Bookmark

    public init(bookmark: any Bookmark) {
        self.bookmark = bookmark
    }

    private var bag = Set<AnyCancellable>()
    private lazy var viewModel: BookmarkViewModelProtocol = {
        let viewModel = BookmarkViewModel(bookmark: bookmark)
        viewModel.eventPublisher.sink { [weak self] event in
            self?.handle(event)
        }
        .store(in: &bag)

        return viewModel
    }()

    public var contentView: some View {
        BookmarkDetailView(viewModel: viewModel)
    }

    private func handle(_ event: BookmarkEvent) {
        switch event {
        case .dismiss:
            dismiss()
        case .delete(let bookmark):
            Task { @MainActor in
                dismiss()

                guard let managedBookmark = bookmark as? NSManagedObject, let context = managedBookmark.managedObjectContext else { return }
                let controller = BookmarkService(managedObjectContext: context)
                try await context.perform {
                    try controller.removeBookmark(identifier: self.bookmark.bookmarkIdentifier, title: self.bookmark.bookmarkTitle)
                }
            }
        }
    }
}
