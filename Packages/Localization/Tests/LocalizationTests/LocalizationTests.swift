import Testing
import SwiftUI
@testable import Localization

class LocalizationTests {

    @Test
    func testLocalization() throws {
        #expect(Localization.Accounts.emptyHint == LocalizedStringKey(stringLiteral: "no accounts hint text"))
    }
}
