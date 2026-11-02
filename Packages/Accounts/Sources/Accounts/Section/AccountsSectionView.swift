//
//  AccountsSectionView.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 02.11.26.
//

import AppIntents
import CoreData
import SwiftUI

import LibraryCore
import LibraryUI
import Localization
import Persistence

/// A scrollable list of all accounts, each showing its loans and charges.
/// People add accounts from the navigation bar and edit an account by tapping it.
struct AccountsSectionView: View {

    @ObservedObject private var viewModel: AccountsSectionViewModel
    @State private var showsAccountCreation = false
    @Environment(\.loanService) private var loanService: any LoanService
    @Environment(\.intent) private var intent: (any AppIntent)?
    @Environment(\.dataStackProvider) private var dataStackProvider
    @Environment(\.localAccountService) private var accountService: LocalAccountService
    @Environment(\.accountCredentialStore) private var accountCredentialStore: AccountCredentialStoring
    @Environment(\.accountActivating) private var accountActivating: AccountActivating

    @SectionedFetchRequest<String, EDAccount>(
        sectionIdentifier: \.accountIdentifier,
        sortDescriptors: [SortDescriptor(\.activated?.intValue, order: .reverse),
                          SortDescriptor(\.accountName, order: .forward)]
    )
    private var accounts: SectionedFetchResults<String, EDAccount>

    init(viewModel: AccountsSectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        // Unlike a `Group`, the stack keeps the sheets presented when the list replaces the empty state,
        // for example when a person adds their first account.
        ZStack {
            if accounts.count > 0 {
                accountList
            } else {
                emptyState
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showsAccountCreation = true
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                }
                .accessibilityLabel(Localization.List.newAccountButtonAccessibilityLabel)
            }
        }
        .navigationDestination(for: AccountEditViewModel.self) { editViewModel in
            AccountEditView(editViewModel, onSave: {})
        }
        .sheet(isPresented: $showsAccountCreation) {
            CreateAccountView()
        }
        .sheet(isPresented: $viewModel.isShowingErrors) {
            ErrorView(errors: viewModel.errors)
        }
    }

    private var emptyState: some View {
        VStack {
            PlaceholderView(imageName: "tray.fill", hint: "no accounts hint text", bundle: .localization)

            Button {
                showsAccountCreation = true
            } label: {
                Text("no accounts add account button title", bundle: .localization)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var accountList: some View {
        List {
            if let intent {
                Section {
                    SiriTipView(intent: intent)
                        .siriTipViewStyle(.automatic)
                        .listRowBackground(Color.clear)
                }
            }

            ForEach(accounts) { section in
                ForEach(section) { account in
                    if account.activated?.boolValue ?? false {
                        AccountOverviewSection(account: account, editViewModel: editViewModel(for: account)) { loan in
                            viewModel.show(loan, loanService: loanService)
                        }
                    } else {
                        Section {
                            InactiveAccountView(account: account)
                        } header: {
                            AccountHeaderLink(editViewModel: editViewModel(for: account)) {
                                Text(account.sectionTitle(.loans))

                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .refreshable { [viewModel] in
            await viewModel.refresh()
        }
    }

    private func editViewModel(for account: EDAccount) -> AccountEditViewModel {
        viewModel.accountEditViewModel(for: account.objectID,
                                       dataStackProvider: dataStackProvider,
                                       accountService: accountService,
                                       accountCredentialStore: accountCredentialStore,
                                       accountActivating: accountActivating)
    }
}

#Preview {
    let dataStackProvider = DataStackProvider()
    let viewModel = AccountsSectionViewModel {
        .finished(hasChanges: false, renewableItems: [], returnedItems: [], errors: [])
    } onLoanSelection: { _, _ in }
    let inMemoryContext: NSManagedObjectContext = {
        dataStackProvider.loadInMemory()

        let account = try! dataStackProvider.createAccount()
        account.accountName = "Kim"
        account.accountUserID = "12345"
        account.accountAvatar = "avatar-tiger"
        account.activated = true

        return dataStackProvider.foregroundManagedObjectContext
    }()
    NavigationStack {
        AccountsSectionView(viewModel: viewModel)
    }
    .environment(\.managedObjectContext, inMemoryContext)
}
