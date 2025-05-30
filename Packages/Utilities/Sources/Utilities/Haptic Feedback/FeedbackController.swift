//
//  FeedbackController.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.01.19.
//  Copyright © 2019 neoneon. All rights reserved.
//

import Foundation
import UIKit

@objc public class FeedbackController: NSObject {

    private static let feedbackGenerator = UINotificationFeedbackGenerator()

    private static func generateFeedback(ofType type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            feedbackGenerator.notificationOccurred(type)
        }
    }
}

// Account Interactions
@objc public extension FeedbackController {

    @objc static func generateActivateAccountSuccessFeedback() {
        generateFeedback(ofType: .success)
    }

    @objc static func generateActivateAccountWarningFeedback() {
        generateFeedback(ofType: .error)
    }

    @objc static func generateActivateAccountErrorFeedback() {
        generateFeedback(ofType: .error)
    }
}

// Bookmark Interactions
@objc public extension FeedbackController {

    @objc static func generateBookmarkErrorFeedback() {
        generateFeedback(ofType: .error)
    }

    @objc static func generateBookmarkSuccessFeedback() {
        generateFeedback(ofType: .success)
    }

    @objc static func generateRemoveBookmarkSuccessFeedback() {
        generateFeedback(ofType: .warning)
    }
}

// Item Interactions
@objc public extension FeedbackController {

    @objc static func generateRenewalErrorFeedback() {
        generateFeedback(ofType: .error)
    }

    @objc static func generateRenewalSuccessFeedback() {
        generateFeedback(ofType: .success)
    }
}
