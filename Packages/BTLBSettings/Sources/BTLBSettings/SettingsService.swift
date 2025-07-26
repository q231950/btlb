//
//  SettingsService.swift
//  
//
//  Created by Martin Kim Dung-Pham on 08.05.23.
//

import Combine
import Foundation
import UIKit

import LibraryCore
import NetworkShim
import Utilities
import Persistence

public final class SettingsService: LibraryCore.SettingsService {

    private let notificationScheduler: any NotificationScheduling
    private let accountService: any AccountService
    private let userDefaults: UserDefaults

    public var publisher = PassthroughSubject<LibraryCore.Setting, Never>()

    public init(notificationScheduler: any NotificationScheduling, accountService: any AccountService, userDefaults: UserDefaults) {
        self.notificationScheduler = notificationScheduler
        self.accountService = accountService
        self.userDefaults = userDefaults
    }

    public var lastAutomaticAccountUpdateDate: Date? {
        userDefaults.latestSuccessfulAccountBackgroundUpdateDate
    }

    public var lastManualAccountUpdateDate: Date? {
        userDefaults.latestSuccessfulManualAccountUpdateDate
    }

    public func toggleAlternateAppIcon() {
        if isAlternateAppIconEnabled {
            UIApplication.shared.setAlternateIconName(nil)
        } else {
            UIApplication.shared.setAlternateIconName("AlternativeAppIcon")
        }
    }

    public var isAlternateAppIconEnabled: Bool {
        UIApplication.shared.alternateIconName != nil
    }

    public var aiRecommenderEnabled: Bool {
        userDefaults.aiRecommenderEnabled
    }

    public func toggleAiRecommenderEnabled() {
        userDefaults.aiRecommenderEnabled.toggle()
    }

    public func notificationsAuthorized() async -> Bool {
        await notificationScheduler.authorized()
    }

    @MainActor public func openSettings() async {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    public func toggleNotificationsEnabled(on isOn: Bool) {
        Task {
            if await notificationScheduler.authorized() {
                userDefaults.notificationsEnabled = isOn
                publisher.send(.notificationsAuthorized(true))
            } else {
                publisher.send(.notificationsAuthorized(false))
            }

            if !isOn {
                // TODO: should remove all notifications, not just loans
                accountService.removeLoansNotifications()
            } else {
                //            let renewableItems = DataStackProvider.shared.renewableItems(in: DataStackProvider.shared.backgroundManagedObjectContext)
                try await AppEventPublisher.shared.sendUpdate(.settingChange(renewableItems: [])) //renewableItems
            }
        }

        userDefaults.notificationsEnabled = isOn
    }

    public func notificationsEnabled() -> Bool {
        userDefaults.notificationsEnabled
    }

    public func loanExpirationNotificationsEnabled() -> Bool {
        userDefaults.accountUpdateNotificationsEnabled
    }

    public func toggleLoanExpirationNotificationsEnabled(on isOn: Bool) {
        userDefaults.accountUpdateNotificationsEnabled = isOn

        if !isOn {
            accountService.removeLoansNotifications()
        }
    }

    public var loanExpirationNotificationsThreshold: UInt {
        get {
            userDefaults.itemExpirationNotificationDaysThreshold
        }
        set {
            userDefaults.itemExpirationNotificationDaysThreshold = newValue
        }
    }

    public var debugEnabled: Bool {
        DebugCenter().enabled
    }

    public func toggleDebugEnabled(on isOn: Bool) {
        var center = DebugCenter()
        center.enabled = isOn
    }
}
