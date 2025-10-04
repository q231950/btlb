//
//  String+LocalizedTests.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 30.08.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import XCTest
import Localization

class StringTests: XCTestCase {

    func testLocalization() {
        let author = "Author".localized(table: .search)
        XCTAssertEqual(author, "Author")
    }

}
