//
//  AccountDetailViewModel.swift
//
//
//  Created by Martin Kim Dung-Pham on 02.09.23.
//

import Foundation
import Combine
import CoreData
import os
import SwiftUI

import Libraries
import LibraryCore
import LibraryUI
import Localization
import Networking
import Persistence
import Utilities

extension AccountEditViewModel: @MainActor Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(managedObjectId)
    }
}

extension AccountEditViewModel: @MainActor Equatable {
    static func == (lhs: AccountEditViewModel, rhs: AccountEditViewModel) -> Bool {
        lhs.managedObjectId == rhs.managedObjectId
    }
}

protocol AccountEditViewModeling: AnyObject {
    var displayNameValueEditViewModel: ValueEditViewModel { get }
    var avatarName: String? { get }
    func updateAvatarName(_ avatarName: String?)
    func updateValues()
    func save()
}

@MainActor
final class AccountEditViewModel: ObservableObject, @MainActor AccountEditViewModeling {

    @Published var isDirty = false
    @Published var account: (any Account)?
    @Published var isShowingLibrarySelection = false
    @Published var showsError = false
    @Published var showSignInFailure = false

    private let managedObjectContext: NSManagedObjectContext
    private let managedObjectId: NSManagedObjectID
    private let accountService: LocalAccountService
    private let accountActivating: AccountActivating?
    private let accountCredentialStore: AccountCredentialStoring?

    private let shirt = WhiteShirt()
    private var cancellables = Set<AnyCancellable>()

    @Published var activationState: ActivationState = .inactive
    @Published var isAuthenticating: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var avatarName: String?
    private var initialAccountActivation = false

    private var onDelete: () -> Void

    lazy var librarySelectionViewModel: LibrarySelectionEditViewModel = .init(selectedLibraryIdentifier: self.account?.library?.identifier, observedValue: librarySelectionObservedValue)
    private lazy var librarySelectionObservedValue: ObservedValue = shirt.observeValue(named: "library") { old, new in
    }

    lazy var displayNameValueEditViewModel: ValueEditViewModel = .init(title: Localization.Detail.displayNameFieldTitle, observedValue: displayNameFieldValue)
    private lazy var displayNameFieldValue: ObservedValue = ObservedValue { old, new in
        print("onSave new: \(new)")
    } onUpdate: { newValue in
        print("onUpdate newValue: \(newValue)")
        self.account?.name = newValue
        try? self.managedObjectContext.save()
    }

    lazy var userNameValueEditViewModel: ValueEditViewModel = .init(title: Localization.Detail.usernameFieldTitle, observedValue: usernameFieldValue)
    private lazy var usernameFieldValue: ObservedValue = shirt.observeValue(named: "username") { [weak self] old, new in
    }

    lazy var passwordValueEditViewModel: ValueEditViewModel = .init(title: Localization.Detail.passwordFieldTitle, isSecure: true, observedValue: passwordFieldValue)
    private lazy var passwordFieldValue: ObservedValue = shirt.observeValue(named: "password") { [weak self] oldPassword, password in
    }

    init(accountService: LocalAccountService,
         accountCredentialStore: AccountCredentialStoring?,
         accountActivating: AccountActivating?,
         managedObjectContext: NSManagedObjectContext,
         managedObjectId: NSManagedObjectID,
         onDelete: @escaping () -> Void) {
        self.accountService = accountService
        self.accountCredentialStore = accountCredentialStore
        self.accountActivating = accountActivating
        self.managedObjectContext = managedObjectContext
        self.managedObjectId = managedObjectId
        self.onDelete = onDelete

        shirt.isDirty
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                self?.isDirty = newValue
                if newValue == false, let account = self?.account, account.isActivated {
                    self?.activationState = .activated(account)
                } else {
                    self?.activationState = .inactive
                }
            }
            .store(in: &cancellables)
    }

    func updateValues() {
        Logger.account.log(level: .info, "Update field values")

        Task {
            let account = await accountService.account(for: managedObjectId, in: managedObjectContext)
            await managedObjectContext.perform {
                account?.name.map { self.displayNameFieldValue.savedText.send($0)}

                self.avatarName = account?.avatar

                let username = account?.username
                self.usernameFieldValue.text = username ?? ""
                self.passwordFieldValue.text = self.accountCredentialStore?.password(for: username) ?? ""
                self.initialAccountActivation = account?.isActivated ?? false
                if let account, account.isActivated {
                    self.activationState = .activated(account)
                } else {
                    self.activationState = .inactive
                }
                self.librarySelectionObservedValue.text = account?.library?.identifier ?? ""

                self.account = account
            }
            self.shirt.save()
        }
    }

    func discardUnsavedChanges() {
        managedObjectContext.rollback()

        updateValues()
    }

    func updateAvatarName(_ avatarName: String?) {
        self.avatarName = avatarName
        account?.avatar = avatarName
        save()
    }

    func saveAndActivateAccount(libraryProvider: LibraryProvider?, accountActivating: AccountActivating) {
        Logger.editAccount.info("saveAndActivateAccount: activating")
        activationState = .activating

        let username = usernameFieldValue.text
        let password = passwordFieldValue.text

        let keychainProvider = KeychainManager()
        let authenticationManager = AuthenticationManager(network: NetworkClient(), keychainManager: keychainProvider)
        let persistentContainer = DataStackProvider.shared.persistentContainer

        guard let account,
              let foregroundManagedObjectContext = persistentContainer?.viewContext,
              let libraryProvider,
              let library = account.library else {
            Logger.editAccount.info("saveAndActivateAccount: bad preconditions")
            return
        }

        Logger.editAccount.info("saveAndActivateAccount: authenticating")
        let libraryModel = LibraryModel(wrapping: library)
        authenticationManager.authenticateAccount(username, password: password, in: libraryModel, context: foregroundManagedObjectContext, libraryProvider: libraryProvider) { signInSuccess, error in

            guard error == nil else {
                Logger.editAccount.info("saveAndActivateAccount: authentication error")
                self.activationState = .error
                return self.showsError = true
            }

            Task { @MainActor in
                if signInSuccess {
                    Logger.editAccount.info("saveAndActivateAccount: authentication success")
                    let credentialStore = AccountCredentialStore(keychainProvider: keychainProvider)
                    try credentialStore.store(password, of: username)

                    account.name = self.displayNameFieldValue.text
                    account.username = username
                    account.library = library

                    Logger.editAccount.info("saveAndActivateAccount: activating account")
                    _ = await accountActivating.activate(account)
                    
                    self.isAuthenticating = false
                    self.isAuthenticated = true
                    self.activationState = .activated(account)

                } else {
                    Logger.editAccount.info("saveAndActivateAccount: authentication failure")
                    self.showSignInFailure = true
                    self.isAuthenticating = false
                    self.isAuthenticated = false
                    self.activationState = .signInFailed

                    account.isActivated = false
                }

                self.save()
            }
        }
    }

    func deleteAccount() async throws {
        try await accountService.deleteAccount(with: managedObjectId)
        onDelete()
    }

    func save() {
        Logger.editAccount.info("save")
        shirt.save()
        do {
            try managedObjectContext.performAndWait {
                Logger.editAccount.info("save managed object context")
                try self.managedObjectContext.save()
            }
        } catch let error {
            assertionFailure("\(error.localizedDescription)")
        }
    }
}
