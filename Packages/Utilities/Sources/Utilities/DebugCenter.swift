//
//  DebugCenter.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 11.02.20.
//  Copyright © 2020 neoneon. All rights reserved.
//

import Foundation

private extension String {
    static let debugEnabled = "debugEnabled"
}

public struct BackgroundFetchInfo: CustomStringConvertible {
    let backgroundFetchCount: Int
    let successfulBackgroundFetchCount: Int
    let notificationRefreshCount: Int
    let successfulBackgroundNotificationRefreshCount: Int
    let emptyRenewableItems: Date?
    let updateErrorOccurredDate: Date?

    public var description: String {
        "\(backgroundFetchCount) fetches (\(successfulBackgroundFetchCount) successful) so far 🦁\n\(notificationRefreshCount) refresh notifications (\(successfulBackgroundNotificationRefreshCount) successful)\nempty renewableItems: \(String(describing: emptyRenewableItems))\nerror: \(String(describing: updateErrorOccurredDate))"
    }
}

public struct DebugCenter {

    public init() {}

    /// Enable/disable debugging
    public var enabled: Bool {
        set {
            UserDefaults.suite.set(newValue, forKey: .debugEnabled)
        }
        get {
            UserDefaults.suite.bool(forKey: .debugEnabled)
        }
    }

    public var backgroundFetchInfo: BackgroundFetchInfo {
        let userDefaults = UserDefaults.suite

        return BackgroundFetchInfo(
            backgroundFetchCount: userDefaults.backgroundFetchCount,
            successfulBackgroundFetchCount: userDefaults.successfulBackgroundFetchCount,
            notificationRefreshCount: userDefaults.backgroundNotificationRefreshCount,
            successfulBackgroundNotificationRefreshCount: userDefaults.successfulBackgroundNotificationRefreshCount,
            emptyRenewableItems: userDefaults.emptyRenewableItems,
            updateErrorOccurredDate: userDefaults.updateErrorOccurredDate)
    }

    public func resetBackgroundFetchInfo() {
        let userDefaults = UserDefaults.suite

        userDefaults.backgroundFetchCount = 0
        userDefaults.successfulBackgroundFetchCount = 0
        userDefaults.backgroundNotificationRefreshCount = 0
        userDefaults.successfulBackgroundNotificationRefreshCount = 0
        userDefaults.emptyRenewableItems = nil
        userDefaults.updateErrorOccurredDate = nil
    }
}
