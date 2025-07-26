//
//  UserDefaults+Suite.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 16.11.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation

public extension UserDefaults {

    private var notificationsEnabledKey: String { "enablePush" }
    private var aiRecommenderEnabledKey: String { "enableAiRecommender" }
    private var latestSuccessfulRenewalCountKey: String { "latestSuccessfulRenewalCount" }
    private var latestAppLaunchCountKey: String { "latestAppLaunchCount" }
    private var accountUpdateNotificationsEnabledKey: String { "accountUpdateNotificationsEnabled" }
    private var itemExpirationNotificationDaysThresholdKey: String { "itemExpirationNotificationDaysThreshold" }
    private var preferredNotificationHourKey: String { "preferredNotificationHour" }
    private var backgroundFetchCountKey: String { "backgroundFetchCount" }
    private var emptyRenewableItemsKey: String { "emptyRenewableItems" }
    private var updateErrorOccurredDateKey: String { "updateErrorOccurredDate" }
    private var successfulBackgroundFetchCountKey: String { "successfulBackgroundFetchCount" }
    private var latestSuccessfulManualAccountUpdateDateKey: String { "latestSuccessfulManualAccountUpdateDate" }
    private var latestSuccessfulAccountBackgroundUpdateDateKey: String { "latestSuccessfulAccountUpdateDate" }
    private var backgroundNotificationRefreshCountKey: String { "backgroundNotificationRefreshCount" }
    private var successfulBackgroundNotificationRefreshCountKey: String { "successfulBackgroundNotificationRefreshCount" }
    private var latestSuccessfulBackgroundNotificationRefreshDateKey: String { "successfulBackgroundNotificationRefreshDate" }
    private var lastAppReviewDateKey: String { "lastAppReviewDate" }

    /// The common BTLB UserDefaults suite with registered defaults.
    static var suite: UserDefaults {
        let suite = UserDefaults(suiteName: "dev.neoneon.btlb.userdefaults") ?? UserDefaults()

        suite.register(defaults: [
            suite.notificationsEnabledKey: true,
            suite.aiRecommenderEnabledKey: true
        ])

        return suite
    }

    var latestSuccessfulRenewalCount: Int {
        get {
            integer(forKey: latestSuccessfulRenewalCountKey)
        }
        set {
            setValue(newValue, forKey: latestSuccessfulRenewalCountKey)
        }
    }

    var latestAppLaunchCount: Int {
        get {
            integer(forKey: latestAppLaunchCountKey)
        }
        set {
            setValue(newValue, forKey: latestAppLaunchCountKey)
        }
    }

    var lastAppReviewDate: Date? {
        get {
            let timeInterval = double(forKey: lastAppReviewDateKey)
            if timeInterval > 0 {
                return Date(timeIntervalSince1970: timeInterval)
            } else {
                return nil
            }
        }
        set {
            setValue(newValue?.timeIntervalSince1970, forKey: lastAppReviewDateKey)
        }
    }

    var latestSuccessfulAccountUpdateDate: Date? {
        switch (latestSuccessfulManualAccountUpdateDate, latestSuccessfulAccountBackgroundUpdateDate) {
        case (.some(let x), .some(let y)): return max(x, y)
        case (.some(let x), .none): return x
        case (.none, .some(let y)): return y
        case (.none, .none): return nil
        }
    }

    var latestSuccessfulManualAccountUpdateDate: Date? {
        get {
            let timeInterval = double(forKey: latestSuccessfulManualAccountUpdateDateKey)
            if timeInterval > 0 {
                return Date(timeIntervalSince1970: timeInterval)
            } else {
                return nil
            }
        }
        set {
            setValue(newValue?.timeIntervalSince1970, forKey: latestSuccessfulManualAccountUpdateDateKey)
        }
    }

    var latestSuccessfulAccountBackgroundUpdateDate: Date? {
        get {
            let timeInterval = double(forKey: latestSuccessfulAccountBackgroundUpdateDateKey)
            if timeInterval > 0 {
                return Date(timeIntervalSince1970: timeInterval)
            } else {
                return nil
            }
        }
        set {
            setValue(newValue?.timeIntervalSince1970, forKey: latestSuccessfulAccountBackgroundUpdateDateKey)
        }
    }

    var notificationsEnabled: Bool {
        get {
            bool(forKey: notificationsEnabledKey)
        }
        set {
            setValue(newValue, forKey: notificationsEnabledKey)
        }
    }

    var aiRecommenderEnabled: Bool {
        get {
            bool(forKey: aiRecommenderEnabledKey)
        }
        set {
            setValue(newValue, forKey: aiRecommenderEnabledKey)
        }
    }

    var accountUpdateNotificationsEnabled: Bool {
        get {
            bool(forKey: accountUpdateNotificationsEnabledKey)
        }
        set {
            setValue(newValue, forKey: accountUpdateNotificationsEnabledKey)
        }
    }

    var backgroundFetchCount: Int {
        get {
            integer(forKey: backgroundFetchCountKey)
        }
        set {
            setValue(newValue, forKey: backgroundFetchCountKey)
        }
    }

    /// for debugging: when was the last time in an account update where renewable items were empty
    var updateErrorOccurredDate: Date? {
        get {
            let timeInterval = double(forKey: updateErrorOccurredDateKey)
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        set {
            let d = newValue?.timeIntervalSinceReferenceDate
            setValue(d, forKey: updateErrorOccurredDateKey)
        }
    }

    /// for debugging: when was the last time in an account update where renewable items were empty
    var emptyRenewableItems: Date? {
        get {
            let timeInterval = double(forKey: emptyRenewableItemsKey)
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        set {
            let d = newValue?.timeIntervalSinceReferenceDate
            setValue(d, forKey: emptyRenewableItemsKey)
        }
    }

    private var defaultPreferredNotificationHour: Int { 6 }
    var preferredNotificationHour: Int {
        get {
            guard value(forKey: preferredNotificationHourKey) != nil else { return defaultPreferredNotificationHour }

            return Int(integer(forKey: preferredNotificationHourKey))
        }
        set {
            setValue(newValue, forKey: preferredNotificationHourKey)
        }
    }

    private var defaultItemExpirationNotificationDaysThreshold: UInt { 3 }
    var itemExpirationNotificationDaysThreshold: UInt {
        get {
            guard value(forKey: itemExpirationNotificationDaysThresholdKey) != nil else { return defaultItemExpirationNotificationDaysThreshold }

            return UInt(integer(forKey: itemExpirationNotificationDaysThresholdKey))
        }
        set {
            setValue(newValue, forKey: itemExpirationNotificationDaysThresholdKey)
        }
    }

    var successfulBackgroundFetchCount: Int {
        get {
            integer(forKey: successfulBackgroundFetchCountKey)
        }
        set {
            setValue(newValue, forKey: successfulBackgroundFetchCountKey)
        }
    }

    var backgroundNotificationRefreshCount: Int {
        get {
            integer(forKey: backgroundNotificationRefreshCountKey)
        }
        set {
            setValue(newValue, forKey: backgroundNotificationRefreshCountKey)
        }
    }

    var successfulBackgroundNotificationRefreshCount: Int {
        get {
            integer(forKey: successfulBackgroundNotificationRefreshCountKey)
        }
        set {
            setValue(newValue, forKey: successfulBackgroundNotificationRefreshCountKey)
        }
    }

    var latestSuccessfulBackgroundNotificationRefreshDate: Date? {
        get {
            let timeInterval = double(forKey: latestSuccessfulBackgroundNotificationRefreshDateKey)
            if timeInterval > 0 {
                return Date(timeIntervalSince1970: timeInterval)
            } else {
                return nil
            }
        }
        set {
            setValue(newValue?.timeIntervalSince1970, forKey: latestSuccessfulBackgroundNotificationRefreshDateKey)
        }
    }
}
