//
//  AccountLoansRows.swift
//
//
//  Created by Martin Kim Dung-Pham on 26.11.22.
//

import Foundation
import SwiftUI
import CoreData
import LibraryUI
import Persistence

/// The loans of a single account, one row per loan, to be placed inside a list section.
public struct AccountLoansRows: View {
    private let onLoanSelection: (Loan) -> Void
    @FetchRequest private var loans: FetchedResults<Loan>

    /// - Parameters:
    ///   - objectId: the managed object identifier of the account whose loans are shown
    ///   - onLoanSelection: called with the loan a person taps
    public init(account objectId: NSManagedObjectID, onLoanSelection: @escaping (Loan) -> Void) {
        self.onLoanSelection = onLoanSelection
        _loans = FetchRequest(
            sortDescriptors: [SortDescriptor(\.loanExpiryDate, order: .forward),
                              SortDescriptor(\.loanTitle, order: .forward)],
            predicate: NSPredicate(format: "loanAccount == %@", objectId)
        )
    }

    public var body: some View {
        ForEach(loans) { loan in
            Button {
                onLoanSelection(loan)
            } label: {
                LoanItemView(loan.objectID)
            }
        }
    }
}

#Preview {
    List {
        AccountLoansRows(account: NSManagedObjectID()) { _ in

        }
    }
}
