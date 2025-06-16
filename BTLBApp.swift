//
//  main.m
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 10/04/2009.
//  Copyright © 2009 neoneon. All rights reserved.
//

import CoreSpotlight
import Observation
import SwiftUI

import BTLBIntents
import BTLBSettings
import LibraryCore
import Loans
import More
import Persistence
import Utilities

@main
struct BTLBApp: App {

    @UIApplicationDelegateAdaptor(EDSyncAppDelegate.self) var appDelegate
    @AppStorage("selectedTabIndex", store: UserDefaults.suite) var selectedTabIndex: Int = 1

    @StateObject var viewModel = AppViewModel.shared

    init() {
        BTLBShortcutsProvider.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            content
                .task {
                    do {
                        try await viewModel.refresh()
                    } catch {
                        viewModel.isRefreshAlertPresented = true
                    }
                }
                .alert("Debug Info", isPresented: $viewModel.isDebugAlertPresented, actions: {
                    Button {
                        viewModel.isDebugAlertPresented = false
                    } label: {
                        Text("Ok")
                    }

                }, message: {
                    Text(viewModel.debugAlertMessage)
                })
                .alert("Refresh Error", isPresented: $viewModel.isRefreshAlertPresented, actions: {
                    Button {
                        viewModel.isRefreshAlertPresented = false
                    } label: {
                        Text("Ok")
                    }

                }, message: {
                    Text("Refresh failed. Please try again later.")
                })
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlight)
                .onOpenURL(perform: handleIncomingURL)
                .environment(\.accountActivating, AccountUpdater())
                .environment(\.accountUpdating, AccountUpdater())
                .environment(\.managedObjectContext,
                              DataStackProvider.shared.foregroundManagedObjectContext)
                .environment(\.loanService, viewModel.loanService)
                .environment(\.localAccountService, viewModel.localAccountRepository)
                .environment(\.accountCredentialStore, viewModel.accountCredentialStore)
                .environment(\.libraryProvider, viewModel.libraryProvider)
                .environment(\.intent, RenewItemsIntent())
        }
    }

    private var content: some View {
        Group {
            switch viewModel.state {
            case .initial:
                EmptyView()
            case .idle:
                Group {
                    if #available(iOS 18.0, *) {
                        tabs
                    } else {
                        legacyTabs
                    }
                }
                .onAppear {
                    viewModel.updateDebugAlertPresented()
                    viewModel.updateLaunchCount()
                }
                .sheet(item: $viewModel.deeplinkLoanContainer) { container in
                    loanView(container.loan)
                }
                .onChange(of: viewModel.route) { oldValue, newValue in
                    switch newValue {
                    case .loans: selectedTabIndex = 1
                    case .search(let query):
                        selectedTabIndex = 0
                        viewModel.searchCoordinator?.prefillSearchQuery(query)
                    case .openSearch:
                        selectedTabIndex = 0
                    case .none: break
                    }
                }
            case .refreshing:
                AppRefreshingView()
            }
        }
    }

    @ViewBuilder
    private func loanView(_ loan: any LibraryCore.Loan) -> some View {
        let loanDetailViewModel = LoanViewModel(
            loanService: viewModel.loanService,
            appReviewService: BTLBSettings.AppReviewService(userDefaults: .suite),
            notificationScheduler: NotificationScheduler(), loan: loan)

        LoanDetailView(loanDetailViewModel) {
            viewModel.deeplinkLoanContainer = nil
        }
        .containInNavigation
    }

    @State private var navigationPath = NavigationPath()

    @available(iOS 18.0, *)
    private var tabs: some View {
        TabView(selection: $selectedTabIndex) {
            Tab(viewModel.loansTitle, systemImage: "tray.full", value: 1) {
                NavigationStack {
                    viewModel.loansCoordinator.view
                        .navigationTitle(viewModel.loansTitle)
                }
            }

            Tab(viewModel.chargesTitle, systemImage: "eurosign.square", value: 2) {
                NavigationStack {
                    viewModel.chargesCoordinator.view
                        .navigationTitle(viewModel.chargesTitle)
                }
            }

            Tab(viewModel.bookmarksTitle, systemImage: "bookmark", value: 3) {
                NavigationStack {
                    viewModel.bookmarksCoordinator.view
                        .navigationTitle(viewModel.bookmarksTitle)
                }
            }

            Tab(viewModel.moreTitle, systemImage: "ellipsis", value: 4) {
                NavigationStack {
                    viewModel.moreCoordinator
                        .view
                }
            }

            Tab(viewModel.searchTitle, systemImage: "doc.text.magnifyingglass", value: 5, role: .search) {
                NavigationStack(path: $navigationPath) {
                    viewModel.searchCoordinator?.view
                        .navigationTitle(viewModel.searchTitle)
                }
            }
        }
    }

    private var legacyTabs: some View {
        TabView(selection: $selectedTabIndex) {

            NavigationStack(path: $navigationPath) {
                viewModel.searchCoordinator?.view
                    .navigationTitle(viewModel.searchTitle)
            }
            .tag(0)
            .tabItem {
                Label(viewModel.searchTitle, systemImage: "doc.text.magnifyingglass")
            }

            NavigationStack {
                viewModel.loansCoordinator.view
                    .navigationTitle(viewModel.loansTitle)
            }
            .tag(1)
            .tabItem {
                Label(viewModel.loansTitle, systemImage: "tray.full")
            }

            NavigationStack {
                viewModel.chargesCoordinator.view
                    .navigationTitle(viewModel.chargesTitle)
            }
            .tag(2)
            .tabItem {
                Label(viewModel.chargesTitle, systemImage: "eurosign.square")
            }

            NavigationStack {
                viewModel.bookmarksCoordinator.view
                    .navigationTitle(viewModel.bookmarksTitle)
            }
            .tag(3)
            .tabItem {
                Label(viewModel.bookmarksTitle, systemImage: "bookmark")
            }

            NavigationStack {
                viewModel.moreCoordinator
                    .view
            }
            .tag(4)
            .tabItem {
                Label(viewModel.moreTitle, systemImage: "ellipsis")
            }
        }
    }

    /// Handles User Activity when the app is launched via Spotlight Search on iOS.
    ///
    /// This function retrieves the identifier from the user activity and then fetches the associated loan from Core Data. If found, it updates the UI to display that particular loan's details.
    /// - Parameter userActivity: Represents an interaction with the system such as a User Activity or Spotlight Search. It provides metadata about the interaction which can be used when updating the app state.
    func handleSpotlight(_ userActivity: NSUserActivity) {
        if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            Task { @MainActor in
                let context = DataStackProvider.shared.foregroundManagedObjectContext

                let loanManagedObjectId = try await DataStackProvider.shared.loan(for: id, in: context)

                guard let loan = context.object(with: loanManagedObjectId) as? Persistence.Loan else { return }

                viewModel.deeplinkLoanContainer = DeeplinkLoanContainer(loan: loan)
            }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        assertionFailure("do not support incoming URLs")
        guard url.scheme == "btlb" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }

        guard let action = components.host, action == "open-recipe" else {
            print("Unknown URL, we can't handle this one!")
            return
        }

        guard let query = components.queryItems?.first(where: { $0.name == "query" })?.value else {
            print("Query not found")
            return
        }

        viewModel.route = .search(query: query)

    }
}
