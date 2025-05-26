//
//  RoundedButton.swift
//  
//
//  Created by Martin Kim Dung-Pham on 03.12.23.
//

import Foundation
import SwiftUI

public struct RoundedButton<Content: View>: View {

    let label: Content
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled: Bool

    public init(_ action: @escaping () -> Void, @ViewBuilder _ label: @escaping () -> Content) {
        self.label = label()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                Spacer()

                label
                    .opacity(isEnabled ? 1 : 0.7)
                    .padding()
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 15,
                                 style: .continuous)
                .fill(Color.primary)
                .opacity(isEnabled ? 1 : 0.3)
            )
        }

    }
}

#Preview {
    RoundedButton({
        
    }) {
        Text("abc")
    }
}
