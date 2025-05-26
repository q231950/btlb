//
//  LoanCoordinator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 27.09.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import ArchitectureX
import LibraryCore
import LibraryUI
import SwiftUI
import Persistence

class LoanCoordinator<ViewModel: LibraryCore.LoanViewModel>: Coordinator {

    var router: Router? = Router()

    let loan: ViewModel

    init(loan: ViewModel) {
        self.loan = loan
    }

    @MainActor var contentView: some View {
        LoanDetailView(loan) {
            self.dismiss()
        }
    }
}
