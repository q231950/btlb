//
//  SignInSuccessView.swift
//
//
//  Created by Martin Kim Dung-Pham on 07.12.23.
//

import CoreData
import SwiftUI

import LibraryCore
import LibraryUI
import Localization
import Persistence

@MainActor
class SignInSuccessViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var libraryName: String = ""
    @Published var avatar: String?
    @Published var loansCount: Int = 0
    @Published var sumOfCharges: Float?
    @Published var nextExpiryDate: Date?
    let managedObjectId: NSManagedObjectID

    init(account: any Account, identifier: NSManagedObjectID) {
        self.managedObjectId = identifier

        defer {
            update(with: account)
        }
    }

    func update(with account: any Account) {
        Task {
            account.name.map { displayName = $0 }
            avatar = account.avatar
            loansCount = account.allLoans.count
            sumOfCharges = account.allCharges.sum
            nextExpiryDate = account.allLoans.sorted { $0.dueDate < $1.dueDate }.first?.dueDate
            account.library?.name.map { libraryName = $0 }
        }
    }
}

struct SignInSuccessView: View {
    @ObservedObject var viewModel: SignInSuccessViewModel
    private let done: () -> Void

    @Environment(\.localAccountService) private var accountService: LocalAccountService
    @Environment(\.accountActivating) private var accountActivating: AccountActivating
    @Environment(\.accountCredentialStore) private var accountCredentialStore: AccountCredentialStoring
    @Environment(\.dataStackProvider) private var dataStackProvider

    init(viewModel: SignInSuccessViewModel, done: @escaping () -> Void) {
        self.viewModel = viewModel
        self.done = done
    }

    var body: some View {
        VStack {
            List {
                Section {
                    Group {
                        HStack {
                            Spacer()
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.green, Color.secondary)
                                .font(.system(size: 60))
                                .padding(.top, 60)
                            Spacer()
                        }

                        HStack {
                            Spacer()
                            Text(Localization.CreateAccount.Success.title)
                                .font(.title)
                                .bold()
                                .padding(.bottom)
                            Spacer()
                        }

                        Text(Localization.CreateAccount.Success.subtitle)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom)

                        Text(Localization.CreateAccount.Success.message(account: viewModel.displayName), bundle: .module)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .listRowSeparator(.hidden)
                }

                Section {
                    NavigationLink(
                        value: AccountEditViewModel(
                            accountService: accountService,
                            accountCredentialStore: accountCredentialStore,
                            accountActivating: accountActivating,
                            managedObjectContext: dataStackProvider.foregroundManagedObjectContext,
                            managedObjectId: viewModel.managedObjectId,
                            dataStackProvider: dataStackProvider,
                            onDelete: {
                                assertionFailure(
                                    "you cannot delete the account during account creation"
                                )
                            })
                    ) {
                        HStack(
                            alignment: .center
                        ) {
                            AvatarView(
                                viewModel.avatar,
                                size: .small
                            )

                            VStack {
                                HStack {
                                    Text(Localization.CreateAccount.Success.editButtonTitle)
                                        .bold()
                                    Spacer()
                                }

                                HStack {
                                    Text("\(viewModel.displayName) • \(viewModel.libraryName)")
                                        .font(.caption)
                                        .italic()
                                    Spacer()
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }

                Section {
                    Group {
                        Text(Localization.CreateAccount.Success.numberOfLoans(count: viewModel.loansCount), bundle: .module)
                            .padding([.leading, .trailing], 10)

                        if let date = viewModel.nextExpiryDate {
                            Text(Localization.CreateAccount.Success.numberOfDaysUntilNextExpiryDate(date: date), bundle: .module)
                                .padding([.leading, .trailing], 10)
                        }

                        if let amount = viewModel.sumOfCharges {
                            Text(Localization.CreateAccount.Success.amountOfCharges(formattedAmount: "\(amount)€"), bundle: .module)
                                .padding([.leading, .trailing], 10)
                        } else {
                            Text(Localization.CreateAccount.Success.noChargesMessage, bundle: .module)
                                .padding([.leading, .trailing], 10)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: AccountEditViewModel.self, destination: { accountEditViewModel in
                AccountDecorationEditView(accountEditViewModel) {
                    Task { @MainActor in
                        if let account = accountEditViewModel.account {
                            viewModel.update(with: account)
                        }
                    }
                }
            })

            RoundedButton({
                done()
            }) {
                Text(Localization.CreateAccount.Success.doneButtonTitle)
            }
            .padding()
        }
    }
}

#if DEBUG
import Mocks
#Preview {
    let dataStackProvider = DataStackProvider()
    let inMemoryContext = dataStackProvider.inMemory()
    return SignInSuccessView(viewModel: SignInSuccessViewModel(account: AccountMock(), identifier: inMemoryContext.0)) {
    }
    .environment(\.dataStackProvider, dataStackProvider)
}

extension DataStackProvider {
    func inMemory() -> (NSManagedObjectID, NSManagedObjectContext) {
        loadInMemory()

        let account = try! createAccount()
        account.accountName = "account II"
        account.accountUserID = "12345"
        account.displayName = "Irma Vep 👩🏻‍🏫"
        account.activated = true

        return (account.objectID, foregroundManagedObjectContext)
    }
}
#endif
