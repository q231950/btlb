//
//  BTLBLoanService.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 16.10.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import CoreData

public class BTLBLoanService: LoanService {
    private let backendService: LoanBackendServicing
    private let bookmarkService: BookmarkServicing

    public init(backendService: LoanBackendServicing, bookmarkService: BookmarkServicing) {
        self.backendService = backendService
        self.bookmarkService = bookmarkService
    }

    @MainActor public func isBookmarked(identifier: String?, title: String?) async throws -> Bool {
        try await bookmarkService.isBookmarked(identifier: identifier, title: title)
    }

    public func toggleBookmarked(_ loan: any Loan) async throws -> Bool {
        try await bookmarkService.toggleBookmarked(loan)
    }

    @MainActor public func renew(loan: any Renewable) async throws -> Result<any LibraryCore.Loan, Error> {
        try await backendService.renew(loan: loan)
    }

    public func initiateUpdate(forAccount accountID: NSManagedObjectID, accountIdentifier temporaryAccountIdentifier: String?, password temporaryPassword: String?, libraryProvider: Any) async throws {
        try await backendService.initiateUpdate(forAccount: accountID,
                                                accountIdentifier: temporaryAccountIdentifier,
                                                password: temporaryPassword,
                                                libraryProvider: libraryProvider)
    }


}

extension BTLBLoanService: LoanInfoService {
    public func nextReturnDate() async -> Date {
        .now
    }

}
