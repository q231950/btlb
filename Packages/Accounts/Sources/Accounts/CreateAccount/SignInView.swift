//
//  SignInView.swift
//
//
//  Created by Martin Kim Dung-Pham on 02.12.23.
//

import Combine
import Foundation
import SwiftUI

import Libraries
import LibraryCore
import LibraryUI
import Localization
import Persistence

struct SignInView: View {

    enum Field: Hashable {
        case username
        case password
    }

    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    @ObservedObject private var viewModel: SignInViewModel
    @Environment(\.libraryProvider) private var libraryProvider: (any LibraryProvider)?
    @Environment(\.accountActivating) private var accountActivating: AccountActivating
    @FetchRequest private var libraries: FetchedResults<Persistence.Library>
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel

        _libraries = FetchRequest(sortDescriptors: [])
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.init(white: 0.4), Color.secondary)
                        .font(.system(size: 60))
                        .padding(.top, 60)


                    Text(Localization.CreateAccount.SignIn.title, bundle: .module)
                        .font(.title)
                        .bold()
                        .padding()

                    librarySelectionButton
                        .padding(.bottom)

                    TextField(Localization.CreateAccount.SignIn.usernamePlaceholder, text: $username)
                        .focused($focusedField, equals: .username)
                        .padding(.bottom)

                    SecureField(Localization.CreateAccount.SignIn.passwordPlaceholder, text: $password)
                        .focused($focusedField, equals: .password)

                    Spacer()
                        .frame(minHeight: 20, maxHeight: .infinity)

                    signInButton
                        .padding(.bottom)
                        .disabled(viewModel.isAuthenticating ||
                                  viewModel.library == nil || username.isEmpty || password.isEmpty)
                }
                .padding()
                .frame(minHeight: geometry.size.height)
            }
            .frame(width: geometry.size.width)
        }
        .disabled(viewModel.isAuthenticating)
        .interactiveDismissDisabled(viewModel.isAuthenticating)
        .sheet(isPresented: $viewModel.isShowingLibrarySelection) {
            librarySelectionView
        }
        .sheet(isPresented: $viewModel.showSignInFailureAlert) {
            SignInFailureView(viewModel: SignInFailureView.ViewModel(library: LibraryModel(wrapping: viewModel.library)))
        }
        .sheet(isPresented: $viewModel.showsError) {
            SignInErrorView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    Task {
                        dismiss()
                    }
                }) {
                    Text("Cancel", bundle: .localization)
                }
            }
        }
    }

    @ViewBuilder private var signInButton: some View {
        RoundedButton( {
            viewModel.handleLogin(username: username,
                                  password: password,
                                  library: viewModel.library,
                                  libraryProvider: libraryProvider,
                                  accountActivator: accountActivating)
        }) {
            if viewModel.isAuthenticating {
                ActivityIndicator(shouldAnimate: .constant(true))
                    .foregroundStyle(.primary)
            } else {
                Text(Localization.CreateAccount.SignIn.signInButtonTitle)
            }
        }
    }

    @ViewBuilder private var librarySelectionButton: some View {
        LibraryButton(name: viewModel.library?.name, subtitle: viewModel.library?.subtitle) {
            viewModel.isShowingLibrarySelection = true
        }
    }

    @ViewBuilder private var librarySelectionView: some View {
        NavigationView {
            LibrarySelectionCoordinator(for: .login) { (library: Persistence.Library) in
                viewModel.library = library
                viewModel.isShowingLibrarySelection = false

                Task { @MainActor in
                    if username.isEmpty {
                        focusedField = .username
                    } else if password.isEmpty {
                        focusedField = .password
                    }
                }
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
                        Text("Cancel", bundle: .localization)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInView(viewModel: SignInViewModel(publisher: CurrentValueSubject<SignInState, Never>(.signedOut)))
    }
}

