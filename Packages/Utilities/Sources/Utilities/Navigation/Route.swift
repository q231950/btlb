//
//  Route.swift
//  Utilities
//
//  Created by Martin Kim Dung-Pham on 02.07.25.
//

import Persistence

public enum Route: Identifiable, Equatable {
    public var id: String {
        switch self {
        case .loans(let loan): loan.barcode
        case .search(let query): query
        case .openSearch: "openSearch"
        }
    }

    case loans(loan: Persistence.Loan)
    case search(query: String)
    case openSearch
}

