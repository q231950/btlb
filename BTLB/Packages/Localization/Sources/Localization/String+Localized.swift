//
//  String+Localized.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 30.08.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation

public enum StringTable: String {
    case accessibles = "Accessibles"
    case account = "Account"
    case activityAndMessages = "ActivityAndMessages"
    case applicationWide = "ApplicationWide"
    case charges = "Charges"
    case favourites = "Favourites"
    case imprint = "Imprint"
    case recommend = "Recommend"
    case summary = "Summary"
    case loans = "Loans"
    case tabbar = "Tabbar"
    case catalogue = "Catalogue"
    case search = "Search"
}

public extension String {

    func localized(table: StringTable) -> String {
        return NSLocalizedString(self, tableName: table.rawValue, bundle: Bundle.main, value: self, comment: self)
    }
}
