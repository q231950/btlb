//
//  LoansSectionCoordinator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 27.09.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

import ArchitectureX

import Bookmarks
import LibraryCore
import LibraryUI
import Persistence
import Utilities

public class LoanSectionDependencies {
    let accountService: AccountServiceProviding

    public init(accountService: AccountServiceProviding) {
        self.accountService = accountService
    }
}

public class LoansSectionCoordinator: Coordinator {

    public var router: Router? = Router()

    private let databaseFactory: DatabaseConnectionProducing
    private let accountUpdater: any AccountUpdating
    private let dependencies: LoanSectionDependencies

    private lazy var viewModel: LoanListViewModel = {
        LoanListViewModel(coordinator: self, accountUpdater: accountUpdater)
    }()

    public init(router: Router? = Router(), databaseFactory: DatabaseConnectionProducing, accountUpdater: any AccountUpdating, dependencies: LoanSectionDependencies) {
        self.router = router
        self.databaseFactory = databaseFactory
        self.accountUpdater = accountUpdater
        self.dependencies = dependencies
    }

    public var contentView: some View {
        LoanList(viewModel: viewModel)
    }
}
