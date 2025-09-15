//
//  CreateAccountView.swift
//
//
//  Created by Martin Kim Dung-Pham on 03.12.23.
//

import Combine
import  CoreData
import Foundation
import SwiftUI

import LibraryCore
import Persistence

enum SignInState: Equatable, Sendable {
    static func == (lhs: SignInState, rhs: SignInState) -> Bool {
        if case .signedIn = lhs, case .signedOut = rhs {
            false
        } else if case .signedOut = lhs, case .signedIn = rhs {
            false
        } else {
            true
        }
    }

    case signedOut
    case signedIn(any LibraryCore.Account)
}

@MainActor
class CreateAccountViewModel: ObservableObject {
    @Published var account: (any Account)?
    @Published var activationState: SignInState = .signedOut

    lazy var signInViewModel: SignInViewModel = SignInViewModel(publisher: signInPublisher)

    private var cancellables = Set<AnyCancellable>()

    var signInPublisher: CurrentValueSubject<SignInState, Never> {
        let publisher = CurrentValueSubject<SignInState, Never>(.signedOut)

        publisher.sink { activationState in
            Task {
                if case let .signedIn(account) = activationState {
                    self.account = account
                }

                self.activationState = activationState
            }
        }.store(in: &cancellables)

        return publisher
    }
}

public struct CreateAccountView: View {

    @ObservedObject var viewModel = CreateAccountViewModel()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            switch viewModel.activationState {
            case .signedOut:
                SignInView(viewModel: viewModel.signInViewModel)
            case .signedIn(let account):
                if let managedAccount = account as? NSManagedObject {
                    SignInSuccessView(viewModel: SignInSuccessViewModel(account: account, identifier: managedAccount.objectID)) {
                        dismiss()
                    }
                }
            }
        }
        .animation(.bouncy, value: viewModel.activationState)
    }
}

#Preview {
    CreateAccountView()
}
