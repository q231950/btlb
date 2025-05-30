//
//  SignInErrorView.swift
//
//
//  Created by Martin Kim Dung-Pham on 07.12.23.
//

import SwiftUI

import LibraryUI
import Localization

struct SignInErrorView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.yellow, Color.secondary)
                .padding(.top, 60)

            Text(Localization.CreateAccount.Error.title)
                .font(.title)
                .bold()
                .padding(.bottom)

            Text(Localization.CreateAccount.Error.message)
                .font(.title3)

            // TODO: it would be nice to have the actual error message here

            Spacer()

            RoundedButton({
                dismiss()
            }) {
                Text(Localization.CreateAccount.Error.dismissButtonTitle)
                    .bold()
                    .foregroundStyle(.primary)
                    .colorInvert()
            }
        }
        .padding()
    }
}

#Preview {
    SignInErrorView()
}
