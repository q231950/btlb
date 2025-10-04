//
//  AccountLoansSection.swift
//  
//
//  Created by Martin Kim Dung-Pham on 26.11.22.
//

import Foundation
import SwiftUI
import CoreData
import LibraryUI
import Persistence
import Accounts

struct AccountLoansSection: View {
    private let title: String
    private let subtitle: String
    private let libraryName: String
    private let avatarImageName: String?
    private let onLoanSelection: (Loan) -> Void
    @FetchRequest private var loans: FetchedResults<Loan>

    public init(title: String, subtitle: String, libraryName: String, account objectId: NSManagedObjectID, avatarImageName: String?, onLoanSelection: @escaping (Loan) -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.libraryName = libraryName
        self.avatarImageName = avatarImageName
        self.onLoanSelection = onLoanSelection
        _loans = FetchRequest(
            sortDescriptors: [SortDescriptor(\.loanExpiryDate, order: .forward),
                              SortDescriptor(\.loanTitle, order: .forward)],
            predicate: NSPredicate(format: "loanAccount == %@", objectId)
        )
    }
    
    var body: some View {
        Section(content: {
            ForEach(loans) { loan in
                Button {
                    onLoanSelection(loan)
                } label: {
                    LoanItemView(loan.objectID)
                }
            }
        }, header: {
                        header(title: title, subtitle: subtitle, libraryName: libraryName)
                            .padding(.bottom, loans.count > 0 ? 10 : 0)
        })
    }

    @ViewBuilder private func header(title: String, subtitle: String, libraryName: String) -> some View {
        HStack {
            ItemView(title: title,
                     subtitle1: subtitle,
                     subtitle2: libraryName,
                     subtitleSystemImageName: "building.columns")

            Spacer()

            AvatarView(avatarImageName, size: .small)
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    AccountLoansSection(title: "abc", subtitle: "subtitle", libraryName: "Hamnburg", account: NSManagedObjectID(), avatarImageName: "avatar-tiger") { _ in

    }
}
