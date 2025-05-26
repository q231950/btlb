//
//  RenewableItem+Notifications.swift
//  
//
//  Created by Martin Kim Dung-Pham on 29.12.22.
//

import Foundation
import LibraryCore

public extension RenewableItem {

    var hasNoExpirationNotificationScheduled: Bool {
        expirationNotificationDate == nil
    }
}
