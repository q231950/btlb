//
//  NotificationSynchronisation.swift
//  
//
//  Created by Martin Kim Dung-Pham on 27.12.22.
//

import Foundation
import Combine
import LibraryCore
import Persistence

public class NotificationSynchronisation: AppEventObserver {

    private var disposeBag = Set<AnyCancellable>()

    private let scheduler: NotificationScheduling

    public init(scheduler: NotificationScheduling) {
        self.scheduler = scheduler
    }

    public var id = UUID()
    public func handle(_ change: AppEventPublisher.AppEvent) async {
        switch change {
        case .accountActivation(count: _, activated: 0, _):
            await scheduler.removeAllNotifications()
        case .accountActivation:
            break
        case .accountsRefreshed(let updateResult, _):
            await scheduler.removeAllNotifications(for: [.accountUpdateNotModified])
            await scheduleAccountUpdateNotification(hasChanges: updateResult.hasChanges)

            await removeAllStatusNotifications()
            await scheduleStatusNotifications(for: updateResult.renewableItems)
        case .settingChange(let renewableItems):
            await removeAllStatusNotifications()
            await scheduleStatusNotifications(for: renewableItems)
        case .renewalSuccess(let item, _):
            await scheduler.removeStatusNotifications(for: [item])
            await scheduler.scheduleNotification(for: .renewalSuccess(item: item))
            await scheduleStatusNotifications(for: [item])
        case .renewalFailure(let title, let barcode):
            await scheduler.scheduleNotification(for: .renewalFailure(title: title, barcode: barcode))
        }
    }

    private func scheduleStatusNotifications(for items: [RenewableItem]) async  {
        await scheduleExpirationReminderNotifications(for: items.filter {
            $0.status == .borrowed
        })
        await scheduleExpiresTodayNotifications(for: items.filter {
            $0.status == .borrowed ||
            $0.status == .expiresToday

        })
        await scheduleExpiredItemNotifications(for: items.filter {
            $0.status == .borrowed ||
            $0.status == .expiresToday ||
            $0.status == .expired
        })
    }

    private func removeAllStatusNotifications() async {
        await scheduler.removeAllNotifications(for: [
            .expirationReminder(item: RenewableItem.placeholder, notificationDate: nil),
            .expiresToday(item: RenewableItem.placeholder, notificationDate: .now),
            .expired(item: RenewableItem.placeholder, notificationDate: .now, repeats: false)])
    }

    private func scheduleAccountUpdateNotification(hasChanges: Bool) async {
        if hasChanges {
            await scheduler.scheduleNotification(for: .accountUpdate)
        } else {
            if await !scheduler.hasDeliveredAccountUpdateNotification() {
                await scheduler.scheduleNotification(for: .accountUpdateNotModified)
            }
        }
    }

    private func scheduleRenewableItemExpirationNotification(for item: RenewableItem) async {
        let notificationDates = expirationReminderNotificationDates(for: item)

        for (index, date) in notificationDates.enumerated() {
            await scheduler.scheduleNotification(for: .expirationReminder(item: item, notificationDate: date), index: index)
        }

        await item.onExpirationNotificationScheduled(notificationDates.first)
    }

    private func scheduleExpiredItemNotification(for item: RenewableItem) async {
        let dates = expiredNotificationDates(for: item)
        await withTaskGroup(of: Void.self) { taskGroup in
            for (index, event) in dates.enumerated() {
                taskGroup.addTask { [weak self] in
                    await self?.scheduler.scheduleNotification(for: .expired(item: item, notificationDate: event.date, repeats: event.repeats), index: index)
                }
            }
        }
    }

    private func scheduleExpiredItemNotifications(for expiredItems: [RenewableItem]) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for item in expiredItems {
                taskGroup.addTask {
                    await self.scheduleExpiredItemNotification(for: item)
                }
            }
        }
    }

    private func scheduleExpirationReminderNotifications(for renewableItems: [RenewableItem]) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for item in renewableItems {
                taskGroup.addTask {
                    await self.scheduleRenewableItemExpirationNotification(for: item)
                }
            }
        }
    }

    private func scheduleExpiresTodayNotifications(for renewableItems: [RenewableItem]) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for item in renewableItems {
                taskGroup.addTask {
                    await self.scheduleExpiresTodayNotification(for: item)
                }
            }
        }
    }

    private func scheduleExpiresTodayNotification(for item: RenewableItem) async {
        let preferredNotificationHour = Int(UserDefaults.suite.preferredNotificationHour)
        let calendar = Calendar.current

        if let date = calendar.date(bySettingHour: preferredNotificationHour, minute: 0, second: 0, of: item.expirationDate) {
            await scheduler.scheduleNotification(for: .expiresToday(item: item, notificationDate: date))

            if date < .now && calendar.isDateInToday(date) {
                let inFiveMinutes = calendar.date(byAdding: .minute, value: 5, to: .now)!

                await scheduler.scheduleNotification(for: .expiresToday(item: item, notificationDate: inFiveMinutes))
            }
        }
    }

    private func expiredNotificationDates(for item: RenewableItem) -> [(date: Date, repeats: Bool)] {
        let calendar = Calendar.current
        var dates = [(date: Date, repeats: Bool)]()

        let preferredNotificationHour = Int(UserDefaults.suite.preferredNotificationHour)
        let daysUntilNextExpirationDate: Int = max(1, -calendar.numberOfDaysBetween(.now, and: item.expirationDate))

        if let date = calendar.date(byAdding: .day, value: daysUntilNextExpirationDate, to: item.expirationDate),
            let eightOClock = calendar.date(bySettingHour: preferredNotificationHour, minute: 0, second: 0, of: date) {

            if eightOClock < .now {
                let tomorrowAtEight = calendar.date(byAdding: .day, value: 1, to: eightOClock)!
                dates.append((date: tomorrowAtEight, repeats: true))
            } else {
                dates.append((date: eightOClock, repeats: true))
            }
        }

        // Sorting them here allows the system to drop some of the notifications scheduled first
        // in case the system doesn't allow for as many notifications as we'd like to schedule❗️
        return dates.sorted { eventA, eventB in
            eventA.date > eventB.date
        }
    }

    /// the dates when a user should be notified about the expiration of a renewable item
    private func expirationReminderNotificationDates(for item: RenewableItem) -> [Date] {
        let calendar = Calendar.current

        let daysUntilExpiration: Int = max(0, calendar.numberOfDaysBetween(.now, and: item.expirationDate))
        let userDefinedThreshold = Int(UserDefaults.suite.itemExpirationNotificationDaysThreshold)
        let daysUntilNextNotification = min(daysUntilExpiration, userDefinedThreshold)
        let preferredNotificationHour = Int(UserDefaults.suite.preferredNotificationHour)

        var dates = [Date]()

        let range = Range(uncheckedBounds: (lower: -daysUntilNextNotification, upper: 0))
        for days in range {
            if let date = calendar.date(byAdding: .day, value: days, to: item.expirationDate),
               let eightOClock = calendar.date(bySettingHour: preferredNotificationHour, minute: 0, second: 0, of: date) {

                if eightOClock > Date.now {
                    dates.append(eightOClock)
                }
            }
        }

        // Sorting them here allows the system to drop some of the notifications scheduled first
        // in case the system doesn't allow for as many notifications as we'd like to schedule❗️
        return dates.sorted(by: >)
    }
}
