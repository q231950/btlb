//
//  BTLBAppViewModel.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 19.11.23.
//  Copyright © 2023 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

import Bookmarks
import BTLBSettings
import Charges
import Libraries
import LibraryCore
import Loans
import Localization
import More
import Persistence
import Search
import Utilities

struct DeeplinkLoanContainer: Identifiable {
    var id: String {
        loan.barcode
    }

    let loan: any LibraryCore.Loan
}

enum Route: Identifiable, Equatable {
    var id: String {
        switch self {
        case .loans(let loan): loan.barcode
        case .search(let query): query
        case .openSearch: "openSearch"
        }
    }

    case loans(loan: Persistence.Loan)
    case search(query: String)
    case openSearch
}

enum AppState {
    case initial
    case refreshing
    case idle
}

class AppViewModel: ObservableObject {

    static var shared: AppViewModel = {
        AppViewModel(debugCenter: DebugCenter(), appReviewService: AppReviewService(userDefaults: .suite), accountUpdater: AccountUpdater())
    }()

    enum Tab {
        case account
        case bookmarks
        case charges
        case loans
        case search
        case settings
    }

    init(debugCenter: DebugCenter, appReviewService: LibraryCore.AppReviewService, accountUpdater: AccountUpdating) {
        self.debugCenter = debugCenter
        self.appReviewService = appReviewService
        self.accountUpdater = accountUpdater

        backendService = DatabaseConnectionFactory()
            .databaseConnection(
                for: DataStackProvider.shared.foregroundManagedObjectContext,
                accountService: AccountScraper()
        )
        bookmarkService = BookmarkService(managedObjectContext: DataStackProvider.shared.foregroundManagedObjectContext)
    }

    func updateLaunchCount() {
        appReviewService.increaseLatestAppLaunchCount(by: 1)
    }

    // MARK: Debugging

    private let debugCenter: DebugCenter
    private let appReviewService: LibraryCore.AppReviewService
    private let accountUpdater: AccountUpdating

    @Published var route: Route?
    @Published var deeplinkLoanContainer: DeeplinkLoanContainer?
    @Published var isDebugAlertPresented: Bool = false
    @Published var isRefreshAlertPresented: Bool = false
    @Published var state: AppState = .initial

    func updateDebugAlertPresented() {
        isDebugAlertPresented = debugCenter.enabled
    }

    var debugAlertMessage: String {
        debugCenter.backgroundFetchInfo.description
    }

    func resetDebugInfo() {
        debugCenter.resetBackgroundFetchInfo()
    }

    @MainActor func refresh() async throws {
        guard lastRefreshIsOlderThan12Hours else { return state = .idle }

        guard try await DataStackProvider.shared.activeAccounts(in: DataStackProvider.shared.foregroundManagedObjectContext).count > 0 else { return state = .idle }

        state = .refreshing

        accountUpdater.update { [weak self] error in
            Task { @MainActor in
                self?.state = .idle

                if error == nil {
                    UserDefaults.suite.latestSuccessfulAccountBackgroundUpdateDate = .now
                } else {
                    self?.isRefreshAlertPresented = true
                }
            }
        }
    }

    private var lastRefreshIsOlderThan12Hours: Bool {
        UserDefaults.suite.latestSuccessfulAccountUpdateDate?.timeIntervalSinceNow ?? 0 < -60 * 60 * 12
    }

    // MARK: Tab Configuration

    @Published var selectedTab: Tab = .account

    // MARK: Bookmarks

    var bookmarksCoordinator = BookmarkListCoordinator(viewModel: BookmarkListViewModel())

    let bookmarkService: BookmarkServicing

    var bookmarksTitle: String = Localization.Titles.bookmarks

    var loansCoordinator = LoansSectionCoordinator(
        databaseFactory: DatabaseConnectionFactory(),
        accountUpdater: AccountUpdater(),
        dependencies: LoanSectionDependencies(
            accountService: AccountScraper()
        )
    )
    var loansTitle = Localization.Titles.loans

    let backendService: LoanBackendServicing

    var chargesCoordinator = ChargeListCoordinator(refreshable: RefreshHandler {
        // TODO: unite the 2 update methods into one
        //        try await AccountUpdater().update(.manual(.now))
        try await AccountUpdater().manualUpdate(at: Date())
    })

    var chargesTitle: String = Localization.Titles.charges

    var searchCoordinator: SearchSectionCoordinator? = {
        guard let container = DataStackProvider.shared.persistentContainer else { return nil }
        let libraryManagedObjectIdentifier = LibraryManager(persistentContainer: container).legacySearchLibrary
        let libraryManagedObject = libraryManagedObjectIdentifier.map { DataStackProvider.shared.foregroundManagedObjectContext.object(with: $0) as? any  LibraryCore.Library
        } ?? nil

        let name = libraryManagedObject?.name ?? "unknown"
        let subtitle = libraryManagedObject?.subtitle ?? ""
        let databaseConnection = DatabaseConnectionFactory().databaseConnection(
            for: DataStackProvider.shared.foregroundManagedObjectContext,
            accountService: AccountScraper()
        ) as? DatabaseConnection

        let searchDependencies = SearchDependencies(
            databaseConnection: databaseConnection,
            searchProvider: SearchScraper(),
            detailsProvider: SearchResultDetailScraper()
        )

        return SearchSectionCoordinator(
            library: LibraryModel(
                name: name,
                subtitle: subtitle,
                identifier: libraryManagedObject?.identifier ?? "unknown",
                baseUrl: libraryManagedObject?.baseURL,
                catalogUrl: libraryManagedObject?.catalogUrl
            ),
            dependencies: searchDependencies
        )
    }()
    
    var searchTitle: String = Localization.Titles.search

    // MARK: More Section

    @MainActor var moreCoordinator = {
        let settingsService = SettingsService(
            notificationScheduler: NotificationScheduler(),
            accountService: AccountRepository.shared, userDefaults: UserDefaults.suite)
        let accountCredentialStore = AccountCredentialStore(keychainProvider: KeychainManager())

        return MoreSectionCoordinator(entries: [.accounts, .about, .settings(settingsService), .openSource])
    }()

    var moreTitle: String = Localization.Titles.more

    var localAccountRepository = {
        LocalAccountRepository(context: DataStackProvider.shared.foregroundManagedObjectContext)
    }()

    lazy var loanService: LoanService = {
        BTLBLoanService(backendService: backendService, bookmarkService: bookmarkService)
    }()

    var accountCredentialStore = AccountCredentialStore(keychainProvider: KeychainManager())

    // TODO: kill the force! !
    var libraryProvider: LibraryProvider = LibraryManager(persistentContainer: DataStackProvider.shared.persistentContainer!) as! LibraryProvider

}
