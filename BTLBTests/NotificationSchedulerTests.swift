//
//  NotificationSchedulerTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 11.05.23.
//

import Foundation
import Rorschach
import XCTest
@testable import LibraryCore

/// ☝️ ``NotificationScheduler`` is part of _Utilities_ but its tests are located in the BTLB unit test target. This is because ``UNUserNotificationCenter`` is accessed internally in ``NotificationScheduler`` and it requires a main bundle to work – this means a host app is required, which is not the available to the _Utilities_ test target.
final class NotificationSchedulerTests: XCTestCase {

    // MARK: - Account Update Notifications

    @MainActor func testNotificationTriggerSetting_accountUpdates() async {
        let scheduler = NotificationScheduler()
        let defaults = UserDefaults()

        expect {
            Given("notifications in general are enabled") {
                defaults.notificationsEnabled = true
            }
            When("the user has enabled `account update` notifications") {
                defaults.accountUpdateNotificationsEnabled = true
            }

            Then("`account update` notifications should trigger") {
                let x = await scheduler.shouldTriggerNotification(of: .accountUpdate, defaults: defaults)
                XCTAssertTrue(x)

                let y = await scheduler.shouldTriggerNotification(of: .accountUpdateNotModified, defaults: defaults)
                XCTAssertTrue(y)
            }
        }
    }

    @MainActor func testNotificationTriggerSetting_accountUpdates_whenNotificationsDisabled() {
        let scheduler = NotificationScheduler()
        let defaults = UserDefaults()

        expect {
            Given("notifications in general are disabled") {
                defaults.notificationsEnabled = false
            }
            When("`account update` notifications are enabled") {
                defaults.accountUpdateNotificationsEnabled = true
            }

            Then("`account update` notifications should not trigger") {
                let x = await scheduler.shouldTriggerNotification(of: .accountUpdate, defaults: defaults)
                XCTAssertFalse(x)

                let y = await scheduler.shouldTriggerNotification(of: .accountUpdateNotModified, defaults: defaults)
                XCTAssertFalse(y)
            }
        }
    }

    @MainActor func testNotificationTriggerSetting_accountUpdates_whenDisabled() {
        let scheduler = NotificationScheduler()
        let defaults = UserDefaults()

        expect {
            Given("notifications in general are enabled") {
                defaults.notificationsEnabled = true
            }
            When("the user has disabled `account update` notifications") {
                defaults.accountUpdateNotificationsEnabled = false
            }

            Then("`account update` notifications should not trigger") {
                let x = await scheduler.shouldTriggerNotification(of: .accountUpdate, defaults: defaults)
                XCTAssertFalse(x)

                let y = await scheduler.shouldTriggerNotification(of: .accountUpdateNotModified, defaults: defaults)
                XCTAssertFalse(y)
            }
        }
    }

    // MARK: - Renewal Notifications

    @MainActor func testNotificationTriggerSetting_renewals() {
        let scheduler = NotificationScheduler()
        let defaults = UserDefaults()

        expect {
            When("the user has notifications enabled") {
                defaults.notificationsEnabled = true
            }

            Then("`renewal` notifications should trigger") {
                let x = await scheduler.shouldTriggerNotification(of: .renewalSuccess(item: self.item), defaults: defaults)
                XCTAssertTrue(x)

                let y = await scheduler.shouldTriggerNotification(of: .renewalFailure(title: "ABC", barcode: "123456789"), defaults: defaults)
                XCTAssertTrue(y)

                let z = await scheduler.shouldTriggerNotification(of: .renewalSuccess(item: self.item), defaults: defaults)
                XCTAssertTrue(z)
            }
        }
    }

    @MainActor func testNotificationTriggerSetting_renewals_whenDisabled() {
        let scheduler = NotificationScheduler()
        let defaults = UserDefaults()

        expect {
            When("the user has notifications disabled") {
                defaults.notificationsEnabled = false
            }

            Then("`renewal` notifications should not trigger") {
                let x = await scheduler.shouldTriggerNotification(of: .renewalFailure(title: "ABC", barcode: "123456789"), defaults: defaults)
                XCTAssertFalse(x)

                let y = await scheduler.shouldTriggerNotification(of: .renewalSuccess(item: self.item), defaults: defaults)
                XCTAssertFalse(y)
            }
        }
    }

    // MARK: Fixtures

    private var item: RenewableItem = {
        RenewableItem(now: .now, title: "ABC", barcode: "123456789", canRenew: true, expirationDate: .distantFuture, expirationNotificationDate: .now) { _ in

        }
    }()

}
