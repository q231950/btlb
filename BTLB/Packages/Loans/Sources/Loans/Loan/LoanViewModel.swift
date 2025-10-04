//
//  LoanViewModel.swift
//  
//
//  Created by Martin Kim Dung-Pham on 28.09.22.
//

import Foundation

import LibraryCore
import LibraryUI
import Localization
import Utilities

public final class LoanViewModel: LibraryCore.LoanViewModel {
    public var id = UUID()

    public static func == (lhs: LoanViewModel, rhs: LoanViewModel) -> Bool {
        type(of: lhs.loan) == type(of: rhs.loan) && lhs.loan.barcode == rhs.loan.barcode
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(loan.barcode)
        hasher.combine(loan.shelfmark)
    }

    private let service: any LoanService
    private let appReviewService: any AppReviewService
    @Published public var loan: any Loan
    @Published public var isBookmarked: Bool = false
    @Published public var showsRenewalConfirmation: Bool = false
    @Published public var notificationDescription: String?
    @Published public var progressButtonState: ProgressButtonState = .idle(systemImageName: "clock.arrow.2.circlepath")
    @Published public var shouldRequestAppReview = false
    private let notificationScheduler: NotificationScheduling

    public init(loanService: any LoanService, appReviewService: any AppReviewService, notificationScheduler: NotificationScheduling, loan: any Loan) {
        self.service = loanService
        self.appReviewService = appReviewService
        self.notificationScheduler = notificationScheduler
        self.loan = loan
    }

    public func updateAsyncProperties() {
        Task { @MainActor in
            isBookmarked = try await service.isBookmarked(identifier: loan.barcode, title: loan.title)
            if let date = await notificationScheduler.pendingNotificationTriggerDate(for: loan.barcode) {
                notificationDescription = notificationDescription(expirationDate: loan.dueDate, notificationDate: date)
            }
        }
    }

    private func notificationDescription(expirationDate: Date?, notificationDate: Date?) -> String? {
        guard let notificationDate else { return nil }
        let calendar = Calendar.current

        return expirationDate.map { date in
            if calendar.isDateInTomorrow(date) {
                return Localization.Loans.Text.notificationTriggerItemExpiresTomorrowDescription
            } else if calendar.isDateInToday(date) {
                return Localization.Loans.Text.notificationTriggerItemExpiresTodayDescription
            } else if date < .now {
                return Localization.Loans.Text.notificationTriggerItemExpiredDescription(notificationDate)
            } else {
                return Localization.Loans.Text.notificationTriggerDateDescription(notificationDate)
            }
        }
    }

    public var lockedByPreorderDescription: String {
        (loan.lockedByPreorder ? "is locked by preorder" : "is not locked by preorder").localized(table: "Localizable", bundle: .module)
    }

    @MainActor public func toggleBookmarked() async {
        do {
            isBookmarked = try await service.toggleBookmarked(loan)
        } catch (let error) {
            print("\(error.localizedDescription)")
        }
    }

    @MainActor public func renew() async throws {
        progressButtonState = .animating(systemImageName: "arrow.triangle.2.circlepath")
        switch try await service.renew(loan: loan) {
        case .success(let newLoan):
            loan = newLoan
            appReviewService.increaseLatestSuccessfulRenewalCount(by: 1)
            shouldRequestAppReview = true
            progressButtonState = .success(systemImageName: "checkmark.circle")
            notificationDescription = notificationDescription(expirationDate: newLoan.dueDate, notificationDate: newLoan.notificationScheduledDate)
            FeedbackController.generateRenewalSuccessFeedback()
        case .failure:
            progressButtonState = .failure(systemImageName: "exclamationmark.arrow.triangle.2.circlepath")
            FeedbackController.generateRenewalErrorFeedback()
        }
    }
}
