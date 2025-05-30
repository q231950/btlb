//
//  NotificationSchedulingMock.swift
//  
//
//  Created by Martin Kim Dung-Pham on 17.03.24.
//

import Foundation

import LibraryCore

public class NotificationSchedulingMock: NotificationScheduling {
    public func authorized() async -> Bool { true }

    public func shouldScheduleNotifications(notificationsEnabled: Bool) async -> Bool { true }

    public func scheduleNotification(for: LibraryCore.NotificationType, index: Int?) async {}

    public func pendingNotificationTriggerDate(for barcode: String) async -> Date? { nil }

    public func hasDeliveredAccountUpdateNotification() async -> Bool { true }

    public func removeAllNotifications() async {}

    public func removeAllNotifications(for types: [LibraryCore.NotificationType]) async {}

    public func removeStatusNotifications(for items: [LibraryCore.RenewableItem]) async {}
}
