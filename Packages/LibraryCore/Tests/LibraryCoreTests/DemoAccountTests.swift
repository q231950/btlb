//
//  DemoAccountTests.swift
//  LibraryCoreTests
//
//  Created by Martin Kim Dung-Pham on 03.11.26.
//

import Foundation
import XCTest

import LibraryCore

final class DemoAccountTests: XCTestCase {

    // MARK: Credentials

    func testMatches_whenDemoCredentials() {
        XCTAssertTrue(DemoAccount.matches(username: "demo", password: "demo"))
    }

    func testMatches_whenOtherPassword() {
        XCTAssertFalse(DemoAccount.matches(username: "demo", password: "secret"))
    }

    func testMatches_whenOtherUsername() {
        XCTAssertFalse(DemoAccount.matches(username: "123456789", password: "demo"))
    }

    func testMatches_isCaseSensitive() {
        XCTAssertFalse(DemoAccount.matches(username: "Demo", password: "demo"))
        XCTAssertFalse(DemoAccount.matches(username: "demo", password: "DEMO"))
    }

    func testMatches_whenCredentialsAreMissing() {
        XCTAssertFalse(DemoAccount.matches(username: nil, password: nil))
        XCTAssertFalse(DemoAccount.matches(username: "demo", password: nil))
        XCTAssertFalse(DemoAccount.matches(username: nil, password: "demo"))
    }

    // MARK: Content

    func testAccount_dueDatesAreRelativeToNow() throws {
        let now = try XCTUnwrap(Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 3, hour: 12)))

        let dueDates = DemoAccount.account(now: now).loans.loans.map(\.dateDue)

        XCTAssertEqual(dueDates, ["05.11.2026", "12.11.2026", "03.11.2026", "24.11.2026", "31.10.2026"])
    }

    func testAccount_barcodesAreUniqueDemoBarcodes() {
        let barcodes = DemoAccount.account(now: .now).loans.loans.map(\.itemNumber)

        XCTAssertEqual(Set(barcodes).count, barcodes.count)
        XCTAssertTrue(barcodes.allSatisfy { $0.hasPrefix(DemoAccount.barcodePrefix) })
    }

    func testAccount_hasRenewableAndNonRenewableLoans() {
        let loans = DemoAccount.account(now: .now).loans.loans

        XCTAssertTrue(loans.contains { $0.canRenew && $0.renewalToken != nil })
        XCTAssertTrue(loans.contains { !$0.canRenew })
        XCTAssertTrue(loans.contains { $0.lockedByPreorder })
    }

    func testAccount_hasOneCharge() throws {
        let charges = try XCTUnwrap(DemoAccount.account(now: .now).balance?.charges)

        XCTAssertEqual(charges.count, 1)
        XCTAssertEqual(charges.first?.amountOwed, 1.5)
    }
}
