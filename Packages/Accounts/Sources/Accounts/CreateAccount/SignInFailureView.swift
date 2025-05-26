//
//  SignInFailureView.swift
//
//
//  Created by Martin Kim Dung-Pham on 06.12.23.
//

import Foundation
import SwiftUI

import LibraryCore
import LibraryUI
import Localization
import Utilities

struct SignInFailureView: View {
    
    class ViewModel: ObservableObject {
        @Published var showPasswordResetPage = false
        var shouldShowPasswordReset: Bool {
            passwordResetUrl != nil
        }

        var hints: [String] {
            var hints = [
                Localization.CreateAccount.Failure.failureHint1,
                Localization.CreateAccount.Failure.failureHint2,
                Localization.CreateAccount.Failure.failureHint3
            ]

            if passwordResetUrl != nil {
                hints += [
                    Localization.CreateAccount.Failure.failureHint4(resetButtonName: Localization.CreateAccount.Failure.resetPasswordButtonTitle)
                ]
            }

            return hints
        }

        let passwordResetUrl: URL?
        
        init(library: LibraryModel?) {
            self.passwordResetUrl = library?.isPublicHamburg ?? false ? URL(string: "https://www.buecherhallen.de/passwort-zuruecksetzen.html") : nil
        }
    }

    @Environment(\.dismiss) var dismiss: DismissAction
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.primary, Color.red)
                .font(.system(size: 60))
                .padding(.top, 60)

            Text(Localization.CreateAccount.Failure.title)
                .font(.title)
                .bold()
                .padding()

            Spacer()
                .frame(height: 10)

            VStack {
                ForEach(viewModel.hints, id: \.self) { bullet in
                    Text(bullet)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 15)
                        .padding([.leading, .trailing], 10)
                }
            }
            .padding()

            Spacer()

            RoundedButton({
                dismiss()
                
            }) {
                Text(Localization.CreateAccount.Failure.dismissButtonTitle)
                    .bold()
                    .foregroundStyle(.primary)
                    .colorInvert()
            }
            .padding(.bottom)

            contentIf(viewModel.shouldShowPasswordReset) {
                Button {
                    viewModel.showPasswordResetPage.toggle()
                } label: {
                    Text(Localization.CreateAccount.Failure.resetPasswordButtonTitle)
                        .bold()
                }
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.showPasswordResetPage) {
            if let url = viewModel.passwordResetUrl {
                SafariViewWrapper(url: url)
            }
        }
    }
}

#Preview {
    SignInFailureView(viewModel: SignInFailureView.ViewModel(library: LibraryModel(name: "", subtitle: "", identifier: "HAMBURG_PUBLIC", baseUrl: nil, catalogUrl: nil)))
}
