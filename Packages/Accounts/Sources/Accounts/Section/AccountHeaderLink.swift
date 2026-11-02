//
//  AccountHeaderLink.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 02.11.26.
//

import SwiftUI

/// The header of an account's section, which opens the editor of the account when a person taps it.
struct AccountHeaderLink<Content: View>: View {
    private let editViewModel: AccountEditViewModel
    private let content: Content

    /// - Parameters:
    ///   - editViewModel: the view model of the editor to open
    ///   - content: what the header shows of the account
    init(editViewModel: AccountEditViewModel, @ViewBuilder content: () -> Content) {
        self.editViewModel = editViewModel
        self.content = content()
    }

    var body: some View {
        NavigationLink(value: editViewModel) {
            HStack {
                content

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        // Keeps the header's own look instead of tinting it like a button.
        .buttonStyle(.plain)
        .accessibilityIdentifier("account item")
    }
}
