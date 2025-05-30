import Foundation
import XCTest

import LibraryCore

final class RenewableItemTests: XCTestCase {

    func testStatus_whenExpired() {
        let now: Date = Calendar.current.startOfDay(for: .now)
        let expirationDate = now.addingTimeInterval(-5)

        let sut = RenewableItem(now: now,
                                title: "Some Title",
                                barcode: "12345",
                                canRenew: true,
                                expirationDate: expirationDate,
                                expirationNotificationDate: nil,
                                onExpirationNotificationScheduled: { _ in })
        XCTAssertEqual(sut.status, .expired)
    }

    func testStatus_whenRenewable() {
        let now: Date = .now
        let expirationDate = now.addingTimeInterval(5 * 24 * 60 * 60)

        let sut = RenewableItem(now: now,
                                title: "Some Title",
                                barcode: "12345",
                                canRenew: true,
                                expirationDate: expirationDate,
                                expirationNotificationDate: nil,
                                onExpirationNotificationScheduled: { _ in })
        XCTAssertEqual(sut.status, .borrowed)
        XCTAssertTrue(sut.canRenew)
    }

    func testStatus_whenNonRenewableNotExpired() {
        let now: Date = .now
        let expirationDate = now.addingTimeInterval(5 * 24 * 60 * 60)

        let sut = RenewableItem(now: now,
                                title: "Some Title",
                                barcode: "12345",
                                canRenew: false,
                                expirationDate: expirationDate,
                                expirationNotificationDate: nil,
                                onExpirationNotificationScheduled: { _ in })
        XCTAssertEqual(sut.status, .borrowed)
        XCTAssertFalse(sut.canRenew)
    }
}
