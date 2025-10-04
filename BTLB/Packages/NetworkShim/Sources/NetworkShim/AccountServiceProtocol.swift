//
//  AccountServiceProtocol.swift
//
//
//  Created by Martin Kim Dung-Pham on 22.03.24.
//

import Foundation

@MainActor
public protocol AccountService {
    /// Removes all notifications related to loan expiration on all accounts
    func removeLoansNotifications()
}
