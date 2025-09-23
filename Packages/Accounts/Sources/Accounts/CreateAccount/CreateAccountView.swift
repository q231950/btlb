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
    @Published var activationState: SignInState

    lazy var signInViewModel: SignInViewModel = SignInViewModel(publisher: signInPublisher)
    private var cancellables: Set<AnyCancellable>

    init(account: (any Account)? = nil, activationState: SignInState = .signedOut, cancellables: Set<AnyCancellable> = Set<AnyCancellable>()) {
        self.account = account
        self.activationState = activationState
        self.cancellables = cancellables
    }

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

    @ObservedObject var viewModel: CreateAccountViewModel
    @Environment(\.dismiss) private var dismiss

    public init() {
        self.init(viewModel: CreateAccountViewModel())
    }

    init(viewModel: CreateAccountViewModel) {
        self.viewModel = viewModel
    }

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

#if DEBUG
class MockAccount: Account {
    var allLoans: [any LibraryCore.Loan] = []

    var allCharges: [any LibraryCore.Charge] = []

    var name: String? = "Irma Vep"

    var username: String? = "Irmion"

    var avatar: String? = AccountTemplate.cat.avatar.imageName

    var isActivated: Bool = true

    var library: (any LibraryCore.Library)?
}
#Preview {
    let mockAccount = MockAccount()
    let viewModel = CreateAccountViewModel(activationState: .signedOut)
    CreateAccountView(viewModel: viewModel)
}
#endif
