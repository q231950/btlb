import SwiftUI

import ArchitectureX

import LibraryCore
import Persistence

public class SettingsSectionCoordinator: Coordinator {

    public var router: Router?
    private let settingsService: any LibraryCore.SettingsService
    let dataStackProvider: DataStackProviding

    private lazy var viewModel: SettingsViewModel = {
        SettingsViewModel(service: settingsService, dataStackProvider: dataStackProvider)
    }()

    public init(router: Router? = nil, settingsService: any LibraryCore.SettingsService, dataStackProvider: DataStackProviding) {
        self.router = router
        self.settingsService = settingsService
        self.dataStackProvider = dataStackProvider
    }

    public var contentView: some View {
        SettingsSectionView(viewModel: viewModel)
    }
}
