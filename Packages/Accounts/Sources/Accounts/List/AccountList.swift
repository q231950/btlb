//
//  AccountList.swift
//
//
//  Created by Martin Kim Dung-Pham on 01.08.23.
//

import CoreData
import SwiftUI

import LibraryCore
import LibraryUI
import Localization
import Persistence

public struct AccountList: View {

    @ObservedObject private var viewModel: AccountListViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext: NSManagedObjectContext
    @Environment(\.localAccountService) private var accountService: LocalAccountService
    @Environment(\.accountActivating) private var accountActivating: AccountActivating
    @Environment(\.accountCredentialStore) private var accountCredentialStore: AccountCredentialStoring

    @FetchRequest<EDAccount>(sortDescriptors: [SortDescriptor(\.activated?.intValue, order: .reverse),
                                               SortDescriptor(\.accountName, order: .forward)])
    private var accounts: FetchedResults<EDAccount>

    public init(viewModel: AccountListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
            List(accounts) { account in
                NavigationLink(value: viewModel.accountDetailViewModel(for: account.objectID,
                                                                       accountService: accountService,
                                                                       accountCredentialStore: accountCredentialStore,
                                                                       accountActivating: accountActivating)) {
                    accountRowItem(account: account)
                }
            }
            .navigationDestination(for: AccountEditViewModel.self, destination: { accountDetailViewModel in
                AccountEditView(accountDetailViewModel, onSave: {

                })
            })
            .navigationTitle(Text(Localization.List.title))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showsAccountCreation, content: {
                CreateAccountView()
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.addAccount) {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                    .accessibilityLabel(Localization.List.newAccountButtonAccessibilityLabel)
                }
        }
    }

    @ViewBuilder private func accountRowItem(account: Account) -> some View {
        HStack {
            AvatarView(account.avatar, size: .small)

            ItemView(title: account.name ?? "",
                     subtitle2: account.library?.name,
                     subtitleSystemImageName: "building.columns")
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    let viewModel = AccountListViewModel(dataStackProvider: DataStackProvider.shared) {}
    var inMemoryContext: NSManagedObjectContext = {
        DataStackProvider.shared.loadInMemory()

        let account2 = try! DataStackProvider.shared.createAccount()
        account2.accountName = "account II"
        account2.accountUserID = "12345"
        account2.accountAvatar = "avatar-tiger"

        return DataStackProvider.shared.foregroundManagedObjectContext
    }()

        NavigationStack {
            AccountList(viewModel: viewModel)
        }
        .environment(\.locale, .init(identifier: "de"))

    .environment(\.managedObjectContext, inMemoryContext)
}

