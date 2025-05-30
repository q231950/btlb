import SwiftUI

import ArchitectureX
import Localization
import Persistence

public class BookmarkListCoordinator<ViewModel: BookmarkListViewModelProtocol>: Coordinator {
    public var router: Router? = Router()

    private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var contentView: some View {
        BookmarkList(viewModel: viewModel, coordinator: self)
    }
}
