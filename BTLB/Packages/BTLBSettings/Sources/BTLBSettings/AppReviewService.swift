//
//  AppReviewService.swift
//
//
//  Created by Martin Kim Dung-Pham on 17.03.24.
//

import Foundation
import UIKit

import LibraryCore

public class AppReviewService: LibraryCore.AppReviewService {
    let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public var shouldRequestAppReview: Bool {
        let countCriteria = latestSuccessfulRenewalCount >= 2 && latestAppLaunchCount >= 2
        switch (countCriteria, lastAppReviewDate) {
        case (true, .none):
            return true
        case (true, .some(let date)):
            let now = Date.now
            return Calendar.current.date(byAdding: .month, value: 8, to: date) ?? now < now
        default: return false
        }
    }

    public func requestWrittenAppReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id383008918?action=write-review") else { return }

        UIApplication.shared.open(url)
    }

    public func resetAppReviewRequestIndicators() {
        userDefaults.latestSuccessfulRenewalCount = 0
        userDefaults.latestAppLaunchCount = 0
        userDefaults.lastAppReviewDate = .now
    }

    /// Increase the latest successful renewal count since its last reset
    /// - Parameter count: by how much the overall count should be increased
    public func increaseLatestSuccessfulRenewalCount(by count: Int) {
        userDefaults.latestSuccessfulRenewalCount += count
    }

    /// Increase the latest app launch count since its last reset
    /// - Parameter count: by how much the overall count should be increased
    public func increaseLatestAppLaunchCount(by count: Int) {
        userDefaults.latestAppLaunchCount += count
    }

    private var latestSuccessfulRenewalCount: Int {
        userDefaults.latestSuccessfulRenewalCount
    }

    private var latestAppLaunchCount: Int {
        userDefaults.latestAppLaunchCount
    }

    private var lastAppReviewDate: Date? {
        userDefaults.lastAppReviewDate
    }
}
