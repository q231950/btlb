//
//  AccountDetail.swift
//
//
//  Created by Martin Kim Dung-Pham on 03.08.23.
//

import Combine
import CoreData
import SwiftUI

import Libraries
import LibraryCore
import LibraryUI
import Localization
import Persistence
import Utilities

struct AccountEditView: View {

    @ObservedObject private var viewModel: AccountEditViewModel
    @Environment(\.libraryProvider) private var libraryProvider: LibraryProvider?
    @Environment(\.accountActivating) private var accountActivating: AccountActivating
    @Environment(\.dataStackProvider) private var dataStackProvider
    @State private var showsDeleteConfirmation = false
    @State var isShowingAvatarSelection = false
    private let onSave: () -> Void

    public init(_ viewModel: AccountEditViewModel, onSave: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        AvatarView(viewModel.avatarName, selected: true) {
                            isShowingAvatarSelection = true
                        }
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    ValueEditView(viewModel.displayNameValueEditViewModel)
                        .textContentType(.nickname)

                    ValueEditView(viewModel.userNameValueEditViewModel)
                        .textContentType(.username)

                    ValueEditView(viewModel.passwordValueEditViewModel)
                        .textContentType(.password)
                }

                
                Section {
                    librarySelectionButton
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)

            Spacer()

            activateButton
                .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .task {
            viewModel.updateValues()
        }
        .onDisappear {
            viewModel.discardUnsavedChanges()
        }
        .sheet(isPresented: $isShowingAvatarSelection) {
            avatarSelectionView
        }
        .sheet(isPresented: $viewModel.isShowingLibrarySelection) {
            librarySelectionView
        }
        .sheet(isPresented: $viewModel.showsError) {
            SignInErrorView()
        }
        .sheet(isPresented: $viewModel.showSignInFailure) {
            SignInFailureView(viewModel: SignInFailureView.ViewModel(library: LibraryModel(wrapping: viewModel.account?.library)))
        }
        .confirmationDialog(Localization.Detail.deleteConfirmationTitle,
                            isPresented: $showsDeleteConfirmation,
                            actions: {
            deleteConfirmationActions
        }, message: {
            Text(Localization.Detail.specificDeleteConfirmationMessage(item: viewModel.account?.name))
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showsDeleteConfirmation.toggle()
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(Localization.Detail.deleteButtonTitle)
            }
        }
        .navigationTitle(Text(Localization.Detail.title))
    }

    @ViewBuilder private var activateButton: some View {
        switch viewModel.activationState {
        case .signInFailed, .inactive, .error:
            RoundedButton({
                viewModel.saveAndActivateAccount(libraryProvider: libraryProvider,
                                                 accountActivating: accountActivating)
            }, {
                Text(viewModel.isDirty ? 
                     Localization.EditAccount.ActivateButtonTitle.authenticate:
                        Localization.EditAccount.ActivateButtonTitle.notActivated)
            })
        case .activating:
            RoundedButton({
            }, {
                ActivityIndicator(shouldAnimate: .constant(true))
            })
            .disabled(true)
        case .activated:
            RoundedButton({
            }, {
                Text(Localization.EditAccount.ActivateButtonTitle.activated)
            })
            .disabled(true)
        }
    }

    @ViewBuilder private var deleteConfirmationActions: some View {
        Button(Localization.Detail.deleteAccountCancelButtonTitle, role: .cancel) {
            showsDeleteConfirmation = false
        }
        .tint(.primary)

        Button(Localization.Detail.deleteConfirmationOk, role: .destructive) {
            Task {
                try await viewModel.deleteAccount()
            }
        }
    }

    @ViewBuilder private var avatarSelectionView: some View {
        NavigationView {
            AvatarSelectionCoordinator(currentlySelected: viewModel.avatarName, onCancel: {
                isShowingAvatarSelection = false
            }) { avatar in
                withAnimation(.smooth) {
                    viewModel.updateAvatarName(avatar)
                    isShowingAvatarSelection = false
                }
            }
            .contentView
        }
    }

    @ViewBuilder private var librarySelectionView: some View {
        NavigationView {
            LibrarySelectionCoordinator<Persistence.Library>(for: .login, persistentContainer: dataStackProvider.persistentContainer, currentlySelected: viewModel.account?.library?.identifier) { (library: Persistence.Library) in
                viewModel.librarySelectionViewModel.selectedLibraryIdentifier = library.identifier
                viewModel.account?.library = library
                viewModel.isShowingLibrarySelection = false
            }
            .contentView
            .navigationTitle(Text("LIBRARIES", tableName: "Applicationwide"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        Task {
                            viewModel.isShowingLibrarySelection = false
                        }
                    }) {
                        Text("CANCEL", tableName: "Applicationwide")
                    }
                }
            }
        }
    }

    @ViewBuilder private var librarySelectionButton: some View {
        LibraryButton(
            name: viewModel.account?.library?.name ?? Localization.Detail.noLibrarySelected,
            subtitle: viewModel.account?.library?.subtitle) {
            viewModel.isShowingLibrarySelection = true
        }
    }

    private var deleteConfirmationAlert: Alert {
        Alert(title: Text(Localization.Detail.deleteConfirmationTitle),
              message: Text(Localization.Detail.specificDeleteConfirmationMessage(item: viewModel.account?.name)),
              primaryButton:
                .cancel({
                    showsDeleteConfirmation = false
                }),
              secondaryButton:
                .destructive(Text(Localization.Detail.deleteConfirmationOk)) {
                    Task {
                        try await viewModel.deleteAccount()
                    }
                }
        )
    }
}

#Preview {
    let dataStackProvider = DataStackProvider()
    let inMemoryContext: (NSManagedObjectContext, NSManagedObjectID) = {
        dataStackProvider.loadInMemory()

        let account = try! dataStackProvider.createAccount()
        account.accountName = "account II"
        account.accountUserID = "12345"
        account.displayName = "Irma Vep 👩🏻‍🏫"
        account.activated = false

        return (dataStackProvider.foregroundManagedObjectContext, account.objectID)
    }()

    let viewModel = AccountEditViewModel(
        accountService: LocalAccountRepository(context: inMemoryContext.0),
        accountCredentialStore: nil,
        accountActivating: nil,
        managedObjectContext: inMemoryContext.0, managedObjectId: inMemoryContext.1, dataStackProvider: dataStackProvider, onDelete: {})

    return NavigationView {
        AccountEditView(viewModel, onSave: {})
    }
}
