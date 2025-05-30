import XCTest
@testable import Localization

final class LocalizationTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Localization.Accounts.emptyHint, "Pretty empty here ☝️ this will change once you have setup your library account.")
    }
}
