//
//  SessionIdentifierParserTests.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 19.09.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import XCTest
import TestUtilitiesCore

@testable import LibraryCore

class SessionIdentifierParserTests: XCTestCase {

    func testParseAccessToken() {
        let data = TestHelper.data(resource: "public-session-identifier-response-body", type: .xml)
        let parser = SessionIdentifierParser()
        let parseResult = parser.parseSessionIdentifier(data: data)
        switch parseResult {
        case .success(let token):
            XCTAssertEqual(token, "3851B8E297C92015FBE3EB3A72D7687B")
        default:
            XCTFail("Failed to parse access token")
        }
    }

    func testEmptyAccessToken() {
        let data = TestHelper.data(resource: "public-incorrect-login-session-identifier-request-body", type: .xml)
        let parser = SessionIdentifierParser()
        let parseResult = parser.parseSessionIdentifier(data: data)
        switch parseResult {
        case .failure:
            XCTAssertTrue(1==1)
        default:
            XCTFail("Failed to parse access token")
        }
    }
}
