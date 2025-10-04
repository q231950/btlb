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

import ArchitectureX

struct DeeplinkLoanContainer: Identifiable {
    var id: String {
        loan.barcode
    }

    let loan: any LibraryCore.Loan
}

enum AppState {
    case initial
    case refreshing
    case idle
}

class AppViewModel: ObservableObject {

    static var shared: AppViewModel = {
        AppViewModel(debugCenter: DebugCenter(), appReviewService: AppReviewService(userDefaults: .suite))
    }()

    enum Tab {
        case account
        case bookmarks
        case charges
        case loans
        case search
        case settings
    }

    init(debugCenter: DebugCenter, appReviewService: LibraryCore.AppReviewService) {
        self.debugCenter = debugCenter
        self.appReviewService = appReviewService
    }

    func updateLaunchCount() {
        appReviewService.increaseLatestAppLaunchCount(by: 1)
    }

    // MARK: Debugging

    private let debugCenter: DebugCenter
    private let appReviewService: LibraryCore.AppReviewService
    private lazy var accountUpdater: AccountUpdating = AccountUpdater(dataStackProvider: dataStackProvider)

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

        guard try await dataStackProvider.activeAccounts(in: dataStackProvider.foregroundManagedObjectContext).count > 0 else { return state = .idle }

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

    @MainActor var bookmarksCoordinator = BookmarkListCoordinator(viewModel: BookmarkListViewModel())

    @MainActor lazy var bookmarkService: BookmarkServicing = BookmarkService(managedObjectContext: dataStackProvider.foregroundManagedObjectContext)

    @MainActor var bookmarksTitle: String = Localization.Titles.bookmarks

    lazy var widgetSynchronisation = WidgetSynchronisation(dataStackProvider: dataStackProvider)
    @MainActor lazy var notificationSynchronisation = NotificationSynchronisation(scheduler: NotificationScheduler())
    lazy var coreSpotlightSynchronisation = CoreSpotlightSynchronisation(dataStackProvider: dataStackProvider)

    lazy var loansCoordinator = LoansSectionCoordinator(
        databaseFactory: DatabaseConnectionFactory(),
        accountUpdater: accountUpdater,
        dependencies: LoanSectionDependencies(
            accountService: AccountScraper()
        )
    )
    var loansTitle = Localization.Titles.loans

    lazy var backendService: LoanBackendServicing = DatabaseConnectionFactory()
        .databaseConnection(
            for: dataStackProvider.foregroundManagedObjectContext,
            accountService: AccountScraper(),
            dataStackProvider: dataStackProvider
        )

    lazy var chargesCoordinator = ChargeListCoordinator(refreshable: RefreshHandler { [weak self] in

        guard let self else { return }

        // TODO: unite the 2 update methods into one
        //        try await AccountUpdater().update(.manual(.now))
        try await self.accountUpdater.manualUpdate(in: self.dataStackProvider.backgroundManagedObjectContext, at: Date())
    })

    var chargesTitle: String = Localization.Titles.charges

    func createSearchCoordinator() -> SearchSectionCoordinator {
        let container = dataStackProvider.persistentContainer!
        let libraryManagedObjectIdentifier = LibraryManager(persistentContainer: container).legacySearchLibrary
        let libraryManagedObject = libraryManagedObjectIdentifier.map { dataStackProvider.foregroundManagedObjectContext.object(with: $0) as? any  LibraryCore.Library
        } ?? nil

        let name = libraryManagedObject?.name ?? "unknown"
        let subtitle = libraryManagedObject?.subtitle ?? ""
        let databaseConnection = DatabaseConnectionFactory().databaseConnection(
            for: dataStackProvider.foregroundManagedObjectContext,
            accountService: AccountScraper(),
            dataStackProvider: dataStackProvider
        ) as? DatabaseConnection

        let searchDependencies = SearchDependencies(
            databaseConnection: databaseConnection,
            searchProvider: SearchScraper(),
            detailsProvider: SearchResultDetailScraper(),
            dataStackProvider: dataStackProvider
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
    }

    lazy var searchCoordinator: SearchSectionCoordinator? = {
        guard let container = dataStackProvider.persistentContainer else { return nil }
        let libraryManagedObjectIdentifier = LibraryManager(persistentContainer: container).legacySearchLibrary
        let libraryManagedObject = libraryManagedObjectIdentifier.map { dataStackProvider.foregroundManagedObjectContext.object(with: $0) as? any  LibraryCore.Library
        } ?? nil

        let name = libraryManagedObject?.name ?? "unknown"
        let subtitle = libraryManagedObject?.subtitle ?? ""
        let databaseConnection = DatabaseConnectionFactory().databaseConnection(
            for: dataStackProvider.foregroundManagedObjectContext,
            accountService: AccountScraper(),
            dataStackProvider: dataStackProvider
        ) as? DatabaseConnection

        let searchDependencies = SearchDependencies(
            databaseConnection: databaseConnection,
            searchProvider: SearchScraper(),
            detailsProvider: SearchResultDetailScraper(),
            dataStackProvider: dataStackProvider
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

    @MainActor lazy var moreCoordinator = {
        let settingsService = SettingsService(
            notificationScheduler: NotificationScheduler(),
            accountService: accountRepository, userDefaults: UserDefaults.suite)
        let accountCredentialStore = AccountCredentialStore(keychainProvider: KeychainManager())

        return MoreSectionCoordinator(entries: [.accounts, .about, .settings(settingsService), .openSource])
    }()

    @MainActor lazy var settingsService: LibraryCore.SettingsService = SettingsService(
        notificationScheduler: NotificationScheduler(),
        accountService: accountRepository, userDefaults: UserDefaults.suite)

    var moreTitle: String = Localization.Titles.more

    lazy var localAccountRepository = LocalAccountRepository(context: dataStackProvider.foregroundManagedObjectContext)

    lazy var dataStackProvider: DataStackProviding = DataStackProvider()

    @MainActor lazy var accountRepository = AccountRepository(dataStackProvider: dataStackProvider)

    @MainActor lazy var loanService: LoanService = {
        BTLBLoanService(backendService: backendService, bookmarkService: bookmarkService)
    }()

    var accountCredentialStore = AccountCredentialStore(keychainProvider: KeychainManager())

    // TODO: kill the force! !
    lazy var libraryProvider: LibraryProvider = LibraryManager(persistentContainer: dataStackProvider.persistentContainer!) as LibraryProvider

}
