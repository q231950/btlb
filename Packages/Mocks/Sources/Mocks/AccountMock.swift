//
//  AccountMock.swift
//
//
//  Created by Martin Kim Dung-Pham on 07.12.23.
//

import Foundation

import LibraryCore

public final class AccountMock: LibraryCore.Account {

    public init() {}

    public var allLoans: [any LibraryCore.Loan] = [LoanMock(), LoanMock()]

    public var allCharges: [any LibraryCore.Charge] = [ChargeMock()]
    
    public var name: String? = "Happy 🐼"

    public var username: String?

    public var avatar: String?

    public var isActivated: Bool = true

    public var library: (any LibraryCore.Library)? = LibraryMock()
}
