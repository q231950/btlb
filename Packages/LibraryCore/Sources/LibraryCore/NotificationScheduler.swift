//
//  NotificationScheduler.swift
//  
//
//  Created by Martin Kim Dung-Pham on 19.11.22.
//

import Foundation
import os.log
import UserNotifications
import Localization

/// Defines the identifier, title and subtitle of a notification
public enum NotificationType {
    case accountUpdate
    case accountUpdateNotModified
    case noAccountActive
    case expirationReminder(item: RenewableItem, notificationDate: Date?)
    case renewalSuccess(item: RenewableItem)
    case renewalFailure(title: String, barcode: String)
    case expiresToday(item: RenewableItem, notificationDate: Date)
    case expired(item: RenewableItem, notificationDate: Date, repeats: Bool)

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long

        return dateFormatter
    }

    var identifier: String {
        switch self {
        case .accountUpdate, .noAccountActive:
            return identifierPrefix
        case .accountUpdateNotModified:
            return "\(identifierPrefix).not-modified"
        case .expirationReminder(let item, _):
            return "\(identifierPrefix).\(item.barcode)"
        case .renewalSuccess(let item):
            return "\(identifierPrefix).\(item.barcode)"
        case .renewalFailure(_, let barcode):
            return "\(identifierPrefix).\(barcode)"
        case .expiresToday(item: let item, _):
            return "\(identifierPrefix).\(item.barcode)"
        case .expired(item: let item, _, _):
            return "\(identifierPrefix).\(item.barcode)"
        }
    }

    var identifierPrefix: String {
        switch self {
        case .accountUpdate, .accountUpdateNotModified:
            return "dev.neoneon.btlb.notification.account.update"
        case .noAccountActive:
            return "dev.neoneon.btlb.notification.account.none-active"
        case .expirationReminder:
            return "dev.neoneon.btlb.notification.item.expiration"
        case .renewalSuccess:
            return "dev.neoneon.btlb.notification.item.renewal-success"
        case .renewalFailure:
            return "dev.neoneon.btlb.notification.item.renewal-failure"
        case .expiresToday:
            return "dev.neoneon.btlb.notification.item.expires-today"
        case .expired:
            return "dev.neoneon.btlb.notification.item.expired"
        }
    }

    fileprivate var category: String? {
        switch self {
        case .accountUpdate, .accountUpdateNotModified, .noAccountActive, .renewalSuccess, .renewalFailure, .expired: return nil
        case .expirationReminder(let item, _): return item.canRenew ? "ITEM_EXPIRATION_RENEWABLE" : "ITEM_EXPIRATION_NOT_RENEWABLE"
        case .expiresToday(let item, _): return item.canRenew ? "ITEM_EXPIRES_TODAY" : "ITEM_EXPIRATION_NOT_RENEWABLE"
            // reload accounts for expired
        }
    }

    fileprivate var interruptionLevel: UNNotificationInterruptionLevel {
        switch self {
        case .accountUpdate, .accountUpdateNotModified, .noAccountActive: return .passive
        case .expirationReminder, .renewalSuccess, .renewalFailure, .expiresToday, .expired: return .timeSensitive
        }
    }

    var trigger: UNNotificationTrigger? {
        switch self {
        case .expirationReminder(_, let notificationDate):
            guard let notificationDate else { return nil }
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        case .accountUpdate, .accountUpdateNotModified, .noAccountActive, .renewalSuccess, .renewalFailure:
            return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        case .expiresToday(_, let notificationDate):
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        case .expired(_, let notificationDate, let repeats):
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        }
    }

    fileprivate var userInfo: [String: Any] {
        switch self {
        case .accountUpdate, .accountUpdateNotModified, .noAccountActive, .renewalSuccess, .renewalFailure, .expired:
            return [:]
        case .expirationReminder(let item, _):
            return ["barcode": item.barcode]
        case .expiresToday(let item, _):
            return ["barcode": item.barcode]
        }
    }

    fileprivate var title: String {
        switch self {
        case .accountUpdate:
            return "notification account update has changes title"
        case .accountUpdateNotModified:
            return "notification account update without changes title"
        case .noAccountActive:
            return "notification account update without account"
        case .expirationReminder(let item, _):
            return NSString(format: "%@", item.title) as String
        case .renewalSuccess:
            return "notification renewal success title"
        case .renewalFailure:
            return "notification renewal failure title"
        case .expiresToday(let item, _):
            return NSString(format: "😲 %@", item.title) as String
        case .expired(let item, _, _):
            return NSString(format: "❗️%@", item.title) as String
        }
    }

    fileprivate var subtitle: String {
        switch self {
        case .accountUpdate:
            return "notification account update has changes subtitle".localized
        case .accountUpdateNotModified:
            return "notification account update without changes subtitle".localized
        case .noAccountActive:
            return "notification account update without account subtitle".localized
        case .expirationReminder(let item, _):
            let formattedDate = dateFormatter.string(from: item.expirationDate)
            return NSString(format: "notification expiration due message".localized as NSString, formattedDate) as String
        case .renewalSuccess(let item):
            let formattedDate = dateFormatter.string(from: item.expirationDate)
            return NSString(format: "notification renewal success subtitle".localized as NSString, item.title, formattedDate) as String
        case .renewalFailure(let title, _):
            return NSString(format: "notification renewal failure subtitle".localized as NSString, title) as String
        case .expiresToday(let item, _):
            if item.canRenew {
                return "notification expires today renewable message".localized
            } else {
                return "notification expires today not renewable message".localized
            }
        case .expired(let item, _, _):
            let formattedDate = dateFormatter.string(from: item.expirationDate)
            return NSString(format: "notification expired message".localized as NSString, formattedDate) as String
        }
    }
}

public protocol NotificationScheduling {
    func authorized() async -> Bool
    func shouldScheduleNotifications(notificationsEnabled: Bool) async -> Bool
    func scheduleNotification(for: NotificationType, index: Int?) async
    func scheduleNotification(for: NotificationType) async
    func pendingNotificationTriggerDate(for barcode: String) async -> Date?
    func hasDeliveredAccountUpdateNotification() async  -> Bool

    /// Removes all notifications, pending as well as delivered ones
    func removeAllNotifications() async
    func removeAllNotifications(for types: [NotificationType]) async
    func removeStatusNotifications(for items: [RenewableItem]) async
}

public extension NotificationScheduling {
    func scheduleNotification(for type: NotificationType) async {
        await scheduleNotification(for: type, index: nil)
    }
}

typealias Filter<T> = (T) -> Bool

/// https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development 👌
@MainActor public struct NotificationScheduler: NotificationScheduling {

    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    public init() {}

    public func authorized() async -> Bool {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                guard (settings.authorizationStatus == .authorized) ||
                        (settings.authorizationStatus == .provisional) else {
                    continuation.resume(with: .success(false))
                    return
                }

                if settings.notificationCenterSetting == .enabled || settings.authorizationStatus == .provisional {
                    continuation.resume(with: .success(true))
                } else {
                    continuation.resume(with: .success(false))
                }
            }
        }
    }

    public func removeAllNotifications() async {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }

    @MainActor public func removeAllNotifications(for types: [NotificationType]) async {

        await withTaskGroup(of: Void.self) { group in

            for type in types {
                group.addTask {
                    let filter = await isNotificationIdentifier(of: type)
                    async let pending = pendingNotificationIdentifiers(filter: filter)
                    async let delivered = deliveredNotificationIdentifiers(filter: filter)

                    let all = await pending + delivered
                    await removeNotifications(with: all)
                }
            }
        }
    }

    @MainActor public func removeStatusNotifications(for items: [RenewableItem]) async {
        await withTaskGroup(of: Void.self) { group in

            for item in items {
                group.addTask {

                    let filter = await isExpirationNotificationIdentifier(of: item)
                    async let pending = pendingNotificationIdentifiers(filter: filter)
                    async let delivered = deliveredNotificationIdentifiers(filter: filter)

                    let all = await pending + delivered
                    await removeNotifications(with: all)
                }
            }
        }
    }

    func isNotificationIdentifier(of type: NotificationType) -> (String) -> Bool {
        {
            $0.hasPrefix(type.identifierPrefix)
        }
    }

    func isExpirationNotificationIdentifier(of item: RenewableItem) -> (String) -> Bool {
        {
            // TODO: remove .now
            $0.hasPrefix(NotificationType.expirationReminder(item: item, notificationDate: .now).identifier)
        }
    }

    public func removeNotifications(with identifiers: [String]) async {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func deliveredNotificationIdentifiers(filter: Filter<String>? = nil) async -> [String] {

        let center = UNUserNotificationCenter.current()

        return await center.deliveredNotifications().map {
            $0.request.identifier
        }.filterIf(filter)
    }

    public func hasDeliveredAccountUpdateNotification() async  -> Bool {
        await deliveredNotificationIdentifiers().contains {
            $0.hasPrefix(NotificationType.accountUpdate.identifierPrefix)
        }
    }

    private var pendingNotificationRequests: [UNNotificationRequest] {
        get async {
            let center = UNUserNotificationCenter.current()
            return await center.pendingNotificationRequests()
        }
    }

    func pendingNotificationIdentifiers(filter: Filter<String>? = nil) async -> [String] {
        await pendingNotificationRequests.map {
            $0.identifier
        }.filterIf(filter)
    }

    public func pendingNotificationTriggerDate(for barcode: String) async -> Date? {
        let allPending = await pendingNotificationRequests

        let requests = allPending.filter { $0.identifier.contains(barcode) }
        let dates: [Date] = requests.compactMap {
            guard let timeIntervalTrigger = $0.trigger as? UNCalendarNotificationTrigger else { return nil }

            return timeIntervalTrigger.nextTriggerDate()
        }

        return dates.sorted(by: <).first
    }

    /// Schedules a notification.
    /// - Parameter type: The type of notification to be triggered.
    public func scheduleNotification(for type: NotificationType, index: Int?) async {

        guard await shouldTriggerNotification(of: type, defaults: UserDefaults.suite) else { return }

        Task {
            let content = UNMutableNotificationContent()
            content.title = type.title.localized
            content.body = type.subtitle
            content.interruptionLevel = type.interruptionLevel
            content.userInfo = type.userInfo
            type.category.map { content.categoryIdentifier = $0 }

            let optionalIdentifierIndex = index != nil ? ".\(index ?? 0)" : ""

            if let trigger = type.trigger {
                let request = UNNotificationRequest(identifier: type.identifier + optionalIdentifierIndex, content: content, trigger: trigger)

                do {
                    try await UNUserNotificationCenter.current().add(request)
                } catch let error {
                    Logger.notifications.error("\(error.localizedDescription)")
                }
            } else {
                Logger.notifications.warning("A notification should have a trigger.")
            }
        }
    }

    /// - Returns: Whether notifications should be scheduled
    public func shouldScheduleNotifications(notificationsEnabled: Bool) async -> Bool {
        await authorized() && notificationsEnabled
    }

    func shouldTriggerNotification(of type: NotificationType, defaults: UserDefaults) async -> Bool {
        guard await shouldScheduleNotifications(notificationsEnabled: defaults.notificationsEnabled) else { return false }

        switch type {
        case .expirationReminder, .renewalFailure, .renewalSuccess, .expiresToday, .expired:
            return true
        case .accountUpdate, .accountUpdateNotModified:
            return defaults.accountUpdateNotificationsEnabled
        default:
            return false
        }
    }
}
