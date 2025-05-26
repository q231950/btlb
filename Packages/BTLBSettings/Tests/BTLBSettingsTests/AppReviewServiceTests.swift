import XCTest

import LibraryCore
import Utilities

@testable import BTLBSettings

class AppReviewServiceTests: XCTestCase {

    let sut = AppReviewService(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)

    func testShouldRequestAppReview() {
        sut.increaseLatestAppLaunchCount(by: 2)
        sut.increaseLatestSuccessfulRenewalCount(by: 2)

        XCTAssertTrue(sut.shouldRequestAppReview)
    }

    func testShouldRequestAppReview_whenCriteriaNotYetMet() {
        sut.increaseLatestAppLaunchCount(by: 1)
        sut.increaseLatestSuccessfulRenewalCount(by: 1)

        XCTAssertFalse(sut.shouldRequestAppReview)
    }

    func testShouldRequestAppReview_takesMoreIntoConsiderationThanAppLaunchCount() {
        sut.increaseLatestAppLaunchCount(by: 2)

        XCTAssertFalse(sut.shouldRequestAppReview)
    }

    func testShouldRequestAppReview_takesMoreIntoConsiderationThanSuccessfulRenewalCount() {
        sut.increaseLatestSuccessfulRenewalCount(by: 2)

        XCTAssertFalse(sut.shouldRequestAppReview)
    }

    func testResets() {
        sut.increaseLatestSuccessfulRenewalCount(by: 2)
        sut.increaseLatestSuccessfulRenewalCount(by: 2)

        sut.resetAppReviewRequestIndicators()

        XCTAssertFalse(sut.shouldRequestAppReview)
    }
}
