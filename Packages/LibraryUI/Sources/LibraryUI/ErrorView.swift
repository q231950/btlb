//
//  ErrorView.swift
//  LibraryUI
//
//  Created by Martin Kim Dung-Pham on 20.02.25.
//

import SwiftUI

import LibraryCore
import Localization

public struct ErrorView: View {

    let errors: [PaperErrorInternal]

    @Environment(\.dismiss) var dismiss

    public init(errors: [PaperErrorInternal]) {
        self.errors = errors
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                ForEach(errors) { error in
                    HStack {
                        Text("• \(error.localizedDescription)")
                        Spacer()
                    }
                }
                .padding(.bottom, 20)

                Button {
                    dismiss()
                } label: {
                    Text("Dismiss error", bundle: .module)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.fraction(0.4)])
    }

    private var title: String {
        if errors.count == 1 {
            Localization.localized("An error occurred!", in: .module)
        } else {
            Localization.localized("Muliple errors occurred!", in: .module)
        }
    }
}

extension PaperErrorInternal {

    var localizedDescription: String {
        switch self {
        case .NotImplementedError(let username):
            Localization.localized(
                "The requested functionality is not yet implemented for the library type of the account with the username: \(username ?? "n\\a")",
                in: .module)
        case .ReqwestError:
            Localization.localized(
                "The network request has failed.",
                in: .module)
        default: "\(self)"
        }
    }
}

#Preview {
    ErrorView(errors: [
        .NotImplementedError(username: "X123456")
    ])
    .environment(\.locale, .init(identifier: "de_DE"))

    ErrorView(errors: [
        .NotImplementedError(username: "X123456"),
        .ReqwestError
    ])
    .environment(\.locale, .init(identifier: "de_DE"))
}
