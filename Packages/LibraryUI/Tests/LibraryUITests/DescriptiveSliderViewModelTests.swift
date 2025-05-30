import XCTest
import SwiftUI

@testable import LibraryUI

final class DescriptiveSliderViewModelTests: XCTestCase {

    let range: ClosedRange<UInt> = ClosedRange(uncheckedBounds: (lower: 2, upper: 10))
    var wrappedValue: UInt = 0
    var value: Binding<UInt>!

    override func setUp() {
        super.setUp()

        value = Binding(
            get: {
                self.wrappedValue
            }, set: {
                self.wrappedValue = $0
            })
    }

    func testRelativeValueFromValue() {
        let viewModel = DescriptiveSlider.ViewModel(title: "", description: "",
                                                    selectedValue: value, in: range)

        XCTAssertEqual(0, viewModel.relativeValue(from: 0, in: range))
        XCTAssertEqual(0.375, viewModel.relativeValue(from: 3, in: range))
        XCTAssertEqual(0.5, viewModel.relativeValue(from: 4, in: range))
        XCTAssertEqual(1, viewModel.relativeValue(from: 8, in: range))
    }

    func testValueFromRelativeValue() {
        let viewModel = DescriptiveSlider.ViewModel(title: "", description: "",
                                                    selectedValue: value, in: range)

        XCTAssertEqual(2, viewModel.value(from: 0, in: range))
        XCTAssertEqual(3, viewModel.value(from: 0.125, in: range))
        XCTAssertEqual(6, viewModel.value(from: 0.5, in: range))
        XCTAssertEqual(10, viewModel.value(from: 1, in: range))
    }
}
