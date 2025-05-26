//
//  AccountTemplateGenerator.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 17.02.25.
//

import Foundation
import SwiftUICore

import LibraryUI

enum AccountTemplate: CaseIterable {
    case cat
    case duck
    case fox
    case horse
    case lion
    case mouse
    case panda
    case poodle
    case rabbit
    case tiger
    case turtle
    case wolf

    var name: String.LocalizationValue {
        switch self {
        case .cat: "account creation sign in account name suggestion cat"
        case .duck: "account creation sign in account name suggestion duck"
        case .fox: "account creation sign in account name suggestion fox"
        case .horse: "account creation sign in account name suggestion horse"
        case .lion: "account creation sign in account name suggestion lion"
        case .mouse: "account creation sign in account name suggestion mouse"
        case .panda: "account creation sign in account name suggestion panda"
        case .poodle: "account creation sign in account name suggestion poodle"
        case .rabbit: "account creation sign in account name suggestion rabbit"
        case .tiger: "account creation sign in account name suggestion tiger"
        case .turtle: "account creation sign in account name suggestion turtle"
        case .wolf: "account creation sign in account name suggestion wolf"
        }
    }

    var avatar: Avatar {
        switch self {
        case .cat: .cat
        case .duck: .duck
        case .fox: .fox
        case .horse: .horse
        case .lion: .lion
        case .mouse: .mouse
        case .panda: .panda
        case .poodle: .poodle
        case .rabbit: .rabbit
        case .tiger: .tiger
        case .turtle: .turtle
        case .wolf: .wolf
        }
    }
}

struct AccountTemplateGenerator {

    static func random() -> AccountTemplate {
        AccountTemplate.allCases.randomElement() ?? .cat
    }
}
