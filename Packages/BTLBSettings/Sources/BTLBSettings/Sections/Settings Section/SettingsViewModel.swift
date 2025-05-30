import Combine
import Foundation
import SwiftUI

import LibraryCore
import LibraryUI
import Persistence
import Utilities
import UIKit

final class SettingsViewModel: ObservableObject {

    private let service: any LibraryCore.SettingsService
    private var bag = Set<AnyCancellable>()
    private let expirationNotificationsThresholds: (lower: UInt, upper: UInt) = (2, 7)

    init(service: any LibraryCore.SettingsService) {
        self.service = service
        self.alternetAppIconEnabled = service.isAlternateAppIconEnabled
        self.loanExpirationNotificationsEnabled = service.loanExpirationNotificationsEnabled()
        self.notificationsEnabled = service.notificationsEnabled()
        self.debugEnabled = service.debugEnabled

        service.publisher.receive(on: RunLoop.main).sink { value in
            switch value {
            case .notificationsEnabled(let enabled): self.notificationsEnabled = enabled
            case .notificationsAuthorized(let enabled): self.notificationsAuthorized = enabled
            }
        }
        .store(in: &bag)
    }

    lazy var descriptiveSliderViewModel: DescriptiveSlider.ViewModel = {
        DescriptiveSlider.ViewModel(
            title: "NOTIFICATION_TIME_TITLE",
            description: "NOTIFICATION_TIME_TEXT",
            bundle: .module,
            selectedValue: loanExpirationNotificationsThreshold,
            in: ClosedRange(uncheckedBounds: (lower: expirationNotificationsThresholds.lower,
                                              upper: expirationNotificationsThresholds.upper))
        )
    }()

    var lastAutomaticAccountUpdateDate: Date? {
        service.lastAutomaticAccountUpdateDate
    }

    var lastManualAccountUpdateDate: Date? {
        service.lastManualAccountUpdateDate
    }

    @Published var alternetAppIconEnabled: Bool {
        didSet {
            service.toggleAlternateAppIcon()
        }
    }

    @Published var notificationsAuthorized: Bool = false

    @Published var notificationsEnabled: Bool = false {
        didSet {
            service.toggleNotificationsEnabled(on: notificationsEnabled)
        }
    }

    @Published var loanExpirationNotificationsEnabled: Bool = false {
        didSet {
            service.toggleLoanExpirationNotificationsEnabled(on: loanExpirationNotificationsEnabled)
        }
    }

    lazy var loanExpirationNotificationsThreshold: Binding<UInt> = Binding(
        get: {
            self.service.loanExpirationNotificationsThreshold
        }, set: {
            self.service.loanExpirationNotificationsThreshold = $0

            Task {
                if let dataStackProvider = DataStackProvider.shared as? SwiftOnlyDataStackProviding {
                    let renewableItems = try await dataStackProvider.renewableItems(in: DataStackProvider.shared.backgroundManagedObjectContext)
                    try await AppEventPublisher.shared.sendUpdate(.settingChange(renewableItems: renewableItems))
                }
            }
        })

    @Published var debugEnabled: Bool {
        didSet {
            service.toggleDebugEnabled(on: debugEnabled)
        }
    }

    @MainActor public func openSettings() async {
        await service.openSettings()
    }

    func updateAsyncProperties() {
        Task { @MainActor in
            self.notificationsAuthorized = await service.notificationsAuthorized()
        }
    }
}
