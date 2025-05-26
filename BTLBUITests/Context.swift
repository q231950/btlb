//
//  Context.swift
//  BTLBUITests
//
//  Created by Martin Kim Dung-Pham on 13.01.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import XCTest

struct Context {
    let app: XCUIApplication?
    let test: XCTestCase

    var loansSection: LoansPage!
    var loanPage: LoanPage!
}
