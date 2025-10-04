//
//  AppIntentRenewalSuccessView.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 14.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import AppIntents
import Foundation
import SwiftUI

import LibraryCore

public struct BTLBIntentsPackage: AppIntentsPackage {}

public extension Array<Result<any Loan, Error>> {

    var errorCount: Int {
        self.filter {
            if case .failure = $0 {
                return true
            }
            return false
        }.count
    }

    var successCount: Int {
        let successfulRenewalsCount = count - errorCount
        return Swift.min(0, successfulRenewalsCount)
    }
}

public struct AppIntentRenewalResultView: View {

    public class ViewModel: ObservableObject {
        @State var allSuccessfullyRenewed: Bool

        /// The number of items a user intended to renew
        @State var selectedMediaCount: Int
        @State var successCount: Int

        public init(results: [Result<any Loan, Error>]) {
            self.allSuccessfullyRenewed = results.errorCount == 0
            self.selectedMediaCount = results.count
            self.successCount = results.count - results.errorCount
        }
    }

    @ObservedObject var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if viewModel.allSuccessfullyRenewed {
                RenewIntentSuccessView(renewedCount: viewModel.selectedMediaCount)
            } else if viewModel.successCount == 0 {
                RenewIntentFailureView(renewAttemptedCount: viewModel.selectedMediaCount)
            } else {
                RenewIntentPartialSuccessView(renewAttemptedCount: viewModel.selectedMediaCount, renewedCount: viewModel.successCount)
            }

        }
        .padding()
    }
}
