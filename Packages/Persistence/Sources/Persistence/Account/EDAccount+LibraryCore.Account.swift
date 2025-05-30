//
//  EDAccount.swift
//  
//
//  Created by Martin Kim Dung-Pham on 04.11.22.
//

import Foundation
import LibraryCore

extension EDAccount: LibraryCore.Account {

    public var allLoans: [any LibraryCore.Loan] {
        loans?.allObjects as? [any LibraryCore.Loan] ?? []
    }

    public var allCharges: [any LibraryCore.Charge] {
        charges?.allObjects as? [any LibraryCore.Charge] ?? []
    }

    public var name: String? {
        get { accountName }
        set { accountName = newValue }
    }

    public var username: String? {
        get { accountUserID }
        set { accountUserID = newValue }
    }

    public var avatar: String? {
        get { accountAvatar }
        set { accountAvatar = newValue }
    }

    public var isActivated: Bool {
        get { Bool(truncating: activated ?? false) }
        set { activated = NSNumber(value: newValue) }
    }

    public var library: (any LibraryCore.Library)? {
        get { accountLibrary }
        set {
            guard let library = newValue as? Persistence.Library else {
                assertionFailure("This should be a persisted library")
                return
            }
            
            accountTypeName = library.name
            accountLibrary = library
            loginSuccess = false
        }
    }
}
