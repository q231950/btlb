//
//  InactiveAccountView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 25.11.22.
//

import Foundation
import SwiftUI
import LibraryCore

public struct InactiveAccountView: View {

    @State private var isActivating = ActivationState.inactive
    @Environment(\.accountActivating) private var accountActivating: AccountActivating

    let account: Account

    public init(account: Account) {
        self.account = account
    }

    public var body: some View {
        switch isActivating {
        case .activating:
            Text("activating copy".localized)
        case .activated:
            EmptyView()
        case .inactive:
            activationRow(text: "not activated copy", actionTitle: "activate account button title")
        case .error:
            activationRow(text: "activation failed copy", actionTitle: "activate account retry button title")
        case .signInFailed:
            Text("activation sign in failed".localized)
        }
    }

    @ViewBuilder private func activationRow(text: String, actionTitle: String) -> some View {
        HStack {
            Text(text.localized)

            Spacer()

            Button {
                isActivating = .activating
                Task { @MainActor in
                    isActivating = await accountActivating.activate(account)
                }
            } label: {
                Text(actionTitle.localized)
            }
            .buttonStyle(.bordered)
        }
    }
}
