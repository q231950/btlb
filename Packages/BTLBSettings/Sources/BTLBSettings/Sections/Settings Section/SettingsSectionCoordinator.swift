import SwiftUI

import ArchitectureX

import LibraryCore

public class SettingsSectionCoordinator: Coordinator {

    public var router: Router?
    private let settingsService: any LibraryCore.SettingsService

    private lazy var viewModel: SettingsViewModel = {
        SettingsViewModel(service: settingsService)
    }()

    public init(router: Router? = nil, settingsService: any LibraryCore.SettingsService) {
        self.router = router
        self.settingsService = settingsService
    }

    public var contentView: some View {
        SettingsSectionView(viewModel: viewModel)
    }
}
