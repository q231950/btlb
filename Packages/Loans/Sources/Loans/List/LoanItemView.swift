//
//  LoanItemView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 18.08.22.
//

import Foundation
import SwiftUI
import CoreData
import Persistence
import LibraryUI

public struct LoanItemView: View {
    @FetchRequest private var loan: FetchedResults<Loan>

    public init(_ objectId: NSManagedObjectID) {
        _loan = FetchRequest(
            sortDescriptors: [],
            predicate: NSPredicate(format: "SELF == %@", objectId)
        )
    }

    public var body: some View {
        if let loan = loan.first {
            ItemView(title: loan.title,
                     subtitle1: loan.shelfmark,
                     subtitle2: loan.dueDate.formatted(date: .long, time: .omitted),
                     subtitleSystemImageName: "calendar")
        } else {
            EmptyView()
        }
    }
}

#if DEBUG

//struct DebugLoan: Loan {
//    var libraryIdentifier: String = "ABC"
//
//    var author: String? = "Author"
//
//    var title: String = "Title Title Title Title Title Title Title Title Title Title Title"
//
//    var subtitle: String = "Subtitle"
//
//    var dueDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: .now)!
//
//    var shelfmark: String = "Shelfmark"
//
//    var renewalCount: Int = 23
//
//    var reservationCount: Int = 42
//
//    var volume: String? = nil
//
//    var barcode: String = "123456789"
//
//    var infos: [LibraryCore.Info] = []
//
//    var id: UUID = UUID()
//}
//
//struct LoanListItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        let loan = DebugLoan()
//        let viewModel = LoanViewModel(loanService: EnvironmentNoopLoanService.shared, loan: loan)
//
//        return LoanItemView(viewModel)
//    }
//}

#endif
