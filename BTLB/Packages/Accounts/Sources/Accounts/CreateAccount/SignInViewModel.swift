//
//  SignInViewModel.swift
//
//
//  Created by Martin Kim Dung-Pham on 16.01.24.
//

import Combine
import Foundation
import SwiftUI

import LibraryCore
import Libraries
import Localization
import NetworkShim
import Networking
import Persistence
import Utilities

final class SignInViewModel: ObservableObject {
    @Published var isShowingLibrarySelection = false
    @Published var isAuthenticating = false

    @Published var library: Persistence.Library?

    @Published var showSignInFailureAlert = false
    @Published var showsError = false

    private var publisher = CurrentValueSubject<SignInState, Never>(.signedOut)
    init(publisher: CurrentValueSubject<SignInState, Never>) {
        self.publisher = publisher
    }

    @MainActor func handleLogin(username: String, password: String, library: Persistence.Library?, libraryProvider: (any LibraryProvider)?, accountActivator: AccountActivating, dataStackProvider: DataStackProviding) {
        let keychainProvider = KeychainManager()
        let authenticationManager = AuthenticationManager(network: NetworkClient(), keychainManager: keychainProvider)
        let persistentContainer = dataStackProvider.persistentContainer

        guard let foregroundManagedObjectContext = persistentContainer?.viewContext,
              let libraryProvider,
              let library else { return }

        isAuthenticating = true

        let libraryModel = LibraryModel(wrapping: library)
        authenticationManager.authenticateAccount(username, password: password, in: libraryModel, context: foregroundManagedObjectContext, libraryProvider: libraryProvider) { signInSuccess, error in

            guard error == nil else {
                Task { @MainActor in
                    self.showsError = true
                    self.isAuthenticating = false
                }
                return
            }

            if signInSuccess {
                let credentialStore = AccountCredentialStore(keychainProvider: keychainProvider)
                Task { @MainActor in
                    try credentialStore.store(password, of: username)

                    let account = try dataStackProvider.createAccount()

                    let accountTemplate = AccountTemplateGenerator.random()
                    account.accountName = Localization.localized(accountTemplate.name)
                    account.accountAvatar = accountTemplate.avatar.imageName
                    account.accountUserID = username
                    account.library = library as any LibraryCore.Library
                    account.accountType = library.identifier
                    account.loginSuccess = true
                    account.activated = true

                    try account.managedObjectContext?.save()

                    _ = await accountActivator.activate(account)

                    Task { @MainActor in
                        self.isAuthenticating = false
                        self.publisher.send(.signedIn(account))
                    }
                }
            } else {
                Task { @MainActor in
                    self.isAuthenticating = false
                    self.showSignInFailureAlert = true
                }
            }
        }
    }
}
