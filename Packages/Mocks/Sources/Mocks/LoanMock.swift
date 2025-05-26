//
//  LoanMock.swift
//
//
//  Created by Martin Kim Dung-Pham on 07.12.23.
//

import Foundation

import LibraryCore

public final class LoanMock: LibraryCore.Loan {

    public var libraryIdentifier: String = "Mock Library Identifier"

    public var author: String? = "author"

    public var title: String = "title"

    public var subtitle: String = "subtitle"

    public var dueDate: Date = .now

    public var shelfmark: String = "shelfmark"

    public var iconUrl: String?

    public var renewalCount: Int = 1

    public var canRenew: Bool = true

    public var renewalToken: String?

    public var lockedByPreorder: Bool = false

    public var volume: String? = nil

    public var barcode: String = "ABC1234567"

    public var infos: [LibraryCore.Info] = []

    public var notificationScheduledDate: Date? = .now

    public static func == (lhs: LoanMock, rhs: LoanMock) -> Bool {
        lhs.barcode == rhs.barcode
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(barcode)
    }
}


