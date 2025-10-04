//
//  LoanList.swift
//  
//
//  Created by Martin Kim Dung-Pham on 18.08.22.
//

import AppIntents
import Combine
import Foundation
import SwiftUI

import BTLBSettings
import Accounts
import Localization
import Persistence
import LibraryCore
import LibraryUI

public struct LoanList<ViewModel: LibraryCore.LoanListViewModel>: View {

    @State private var showsAccountCreation = false
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.loanService) private var loanService: LoanService
    @Environment(\.intent) private var intent: (any AppIntent)?
    @Environment(\.dataStackProvider) private var dataStackProvider

    @SectionedFetchRequest<String, EDAccount>(
        sectionIdentifier: \.accountIdentifier,
        sortDescriptors: [SortDescriptor(\.activated?.intValue, order: .reverse),
                          SortDescriptor(\.accountName, order: .forward)]
    )
    private var accounts: SectionedFetchResults<String, EDAccount>

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if !showsAccountCreation && accounts.count > 0 {
                accountList()
            } else {
                VStack {
                    PlaceholderView(imageName: "tray.fill", hint: Localization.Accounts.emptyHint, bundle: .localization)

                    createAccountButton
                }
                .padding()

            }
        }
        .navigationTitle(Localization.Titles.loans)
        .sheet(isPresented: $showsAccountCreation) {
            CreateAccountView()
        }
        .sheet(isPresented: $viewModel.isShowingErrors) {
            ErrorView(errors: viewModel.errors)
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

    @ViewBuilder private func accountList() -> some View {
        List {
            if let intent {
                Section {
                    SiriTipView(intent: intent)
                        .siriTipViewStyle(.automatic)
                        .listRowBackground(Color.clear)
                }
            }

            ForEach(accounts) { sections in
                ForEach(sections) { account in
                    if account.activated?.boolValue ?? false {
                        let count = (account.loans?.count ?? 0)
                        let itemsText = count == 1 ? "account header item" : "account header items"
                        let subtitle = "(\(count) \(itemsText.localized))"

                        AccountLoansSection(
                            title: account.sectionTitle(.loans),
                            subtitle: subtitle,
                            libraryName: account.accountLibrary?.name ?? "",
                            account: account.objectID,
                            avatarImageName: account.avatar
                        ) { selectedLoan in
                            viewModel.show(LoanViewModel(loanService: loanService,
                                                         appReviewService: BTLBSettings.AppReviewService(userDefaults: .suite), notificationScheduler: NotificationScheduler(), loan: selectedLoan))
                        }
                    } else {
                        Section(header: Text(account.sectionTitle(.loans))) {
                            InactiveAccountView(account: account)
                        }
                    }
                }
            }
        }
        .refreshable {
            do {
                try await viewModel.refresh(in: dataStackProvider.foregroundManagedObjectContext)
            } catch let error{
                print("handle me \(error.localizedDescription)")
            }
        }
    }
}

#if DEBUG
import CoreData

public class PreviewLoanListViewModel: LibraryCore.LoanListViewModel {
    public var errors: [LibraryCore.PaperErrorInternal] = []
    

    public var id = UUID()

    public var isShowingErrors: Bool = false

    public func activate(_ account: LibraryCore.Account) async -> ActivationState {
        .activated(account)
    }

    public func refresh(in context: NSManagedObjectContext) async throws {
        print("refreshing")
    }

    public func show(_ loan: some LibraryCore.LoanViewModel) {
        print("showing")
    }

}

struct LoanList_Previews: PreviewProvider {
    private static let viewModel = PreviewLoanListViewModel()
    static var previews: some View {
        LoanList(viewModel: viewModel)
    }
}
#endif
