import XCTest
@testable import LibraryCore

final class LibraryCoreTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(LibraryModel(name: "Bücherhallen Hamburg",
                                    identifier: "HAMBUE",
                                    type: .hamburgPublic).name, "Bücherhallen Hamburg")
    }
}
