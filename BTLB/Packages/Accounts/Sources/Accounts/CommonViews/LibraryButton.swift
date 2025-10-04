//
//  LibraryButton.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 13.02.25.
//

import Foundation
import SwiftUI

import Localization

struct LibraryButton: View {
    let name: String?
    let subtitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "building.columns.circle")
                    .font(.system(size: 30, weight: .regular))

                VStack(alignment: .leading) {
                    Text(name ?? Localization.CreateAccount.SignIn.librarySelectionPlaceholder)
                        .font(.headline)

                    subtitle.map {
                        Text($0)
                            .font(.subheadline)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom])
    }
}

#Preview {
    LibraryButton(name: "Hamburg", subtitle: "Library of the north", action: {})
}
