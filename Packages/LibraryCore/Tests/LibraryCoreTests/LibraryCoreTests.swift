import XCTest
@testable import LibraryCore

final class LibraryCoreTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(LibraryModel(name: "Bücherhallen Hamburg",
                                    subtitle: nil,
                                    identifier: "HAMBUE").name, "Bücherhallen Hamburg")
    }
}
