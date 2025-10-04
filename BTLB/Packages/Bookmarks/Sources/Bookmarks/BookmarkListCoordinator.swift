import SwiftUI

import ArchitectureX
import LibraryCore
import Localization
import Persistence

@MainActor public class BookmarkListCoordinator<ViewModel: BookmarkListViewModelProtocol>: @MainActor Coordinator {
    public var router: Router? = Router()

    private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var contentView: some View {
        BookmarkList(viewModel: viewModel, coordinator: self)
    }

    func startRecommendationFlow(with bookmarks: [any LibraryCore.Bookmark]) {
        transition(to: AiRecommendationBookmarkSelectionCoordinator(bookmarks: bookmarks), style: .present(modalInPresentation: false))
    }
}
