import XCTest
import Utilities

final class CalendarTests: XCTestCase {

    func testDaysBetween() throws {
        let now: Date = .now

        var in27Days = Calendar.current.date(byAdding: .day, value: 27, to: now)
        in27Days = Calendar.current.date(byAdding: .hour, value: 2, to: in27Days!)

        XCTAssertEqual(Calendar.current.numberOfDaysBetween(now, and: in27Days!), 27)
    }
}
