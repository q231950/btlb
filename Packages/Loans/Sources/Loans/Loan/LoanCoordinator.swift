//
//  LoanCoordinator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 27.09.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import ArchitectureX
import BTLBSettings
import LibraryCore
import LibraryUI
import SwiftUI
import Persistence

/// Presents the details of a single loan.
public class LoanCoordinator<ViewModel: LibraryCore.LoanViewModel>: Coordinator {

    public var router: Router? = Router()

    let loan: ViewModel

    public init(loan: ViewModel) {
        self.loan = loan
    }

    @MainActor public var contentView: some View {
        LoanDetailView(loan)
            .presentationDetents([.medium, .large])
    }
}

/// Presents the details of a single loan, set up with the app's own services.
public typealias LoanDetailCoordinator = LoanCoordinator<LoanViewModel>

public extension LoanCoordinator where ViewModel == LoanViewModel {

    /// Creates a coordinator for the details of a loan.
    /// - Parameters:
    ///   - loan: the loan to show the details of
    ///   - loanService: the service that renews and bookmarks the loan
    @MainActor convenience init(loan: any LibraryCore.Loan, loanService: any LoanService) {
        self.init(loan: LoanViewModel(loanService: loanService,
                                      appReviewService: BTLBSettings.AppReviewService(userDefaults: .suite),
                                      notificationScheduler: NotificationScheduler(),
                                      loan: loan))
    }
}
