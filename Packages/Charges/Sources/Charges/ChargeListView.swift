//
//  ChargeListView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.02.23.
//

import Foundation
import SwiftUI

import Accounts
import LibraryUI
import Localization
import Persistence

struct ChargeListView: View {

    @SectionedFetchRequest<String, EDAccount>(
        sectionIdentifier: \.accountIdentifier,
        sortDescriptors: [SortDescriptor(\.activated?.intValue, order: .reverse),
                          SortDescriptor(\.accountName, order: .forward)]
    )
    private var accounts: SectionedFetchResults<String, EDAccount>
    private let viewModel: ChargeListViewModelProtocol
    @State private var showsAccountCreation = false

    init(viewModel: ChargeListViewModelProtocol) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if !showsAccountCreation && accounts.count > 0 {
                accountList
                    .refreshable {
                        do {
                            try await viewModel.refresh()
                        } catch let error{
                            print("handle me \(error.localizedDescription)")
                        }
                    }
            } else {
                VStack {
                    PlaceholderView(imageName: "eurosign", hint: Localization.Accounts.emptyHint, bundle: .localization)

                    createAccountButton
                }
                .padding()
            }
        }
        .sheet(isPresented: $showsAccountCreation) {
            CreateAccountView()
        }
    }

    @ViewBuilder private var createAccountButton: some View {
        Button {
            showsAccountCreation = true
        } label: {
            Text(Localization.Accounts.addAccountButtonTitle, bundle: .localization)
        }
        .buttonStyle(.bordered)
    }

    @ViewBuilder private var accountList: some View {
        List {
            ForEach(accounts) { sections in
                ForEach(sections) { account in
                    if account.activated?.boolValue ?? false {
                        ChargesAccountSection(title: account.sectionTitle(.charges),
                                              subtitle: account.accountLibrary?.name ?? "", account: account.objectID)
                    } else {
                        Section(header: Text(account.sectionTitle(.charges))) {
                            InactiveAccountView(account: account)
                        }
                    }
                }
            }
        }
    }
}
