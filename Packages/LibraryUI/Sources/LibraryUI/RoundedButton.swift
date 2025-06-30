//
//  RoundedButton.swift
//  
//
//  Created by Martin Kim Dung-Pham on 03.12.23.
//

import Foundation
import SwiftUI

public enum RoundedButtonStyle {
    case primary
    case secondary
}

public struct RoundedButton<Content: View>: View {

    let label: Content
    let action: () -> Void
    let style: RoundedButtonStyle

    @Environment(\.isEnabled) private var isEnabled: Bool

    public init(style: RoundedButtonStyle = .primary, _ action: @escaping () -> Void, @ViewBuilder _ label: @escaping () -> Content) {
        self.style = style
        self.label = label()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                Spacer()

                Group {
                    if style == .primary {
                        label
                            .bold()
                            .foregroundStyle(.primary)
                            .colorInvert()
                    } else {
                        label
                            .bold()
                            .foregroundStyle(.primary)
                    }
                }
                .opacity(isEnabled ? 1 : 0.7)
                .padding()
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 15,
                                 style: .continuous)
                .fill(style == .primary ? Color.primary : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(Color.primary, lineWidth: style == .secondary ? 3 : 0)
                )
                .opacity(isEnabled ? 1 : 0.3)
            )
        }

    }
}

#Preview {
    VStack(spacing: 20) {
        RoundedButton({
            
        }) {
            Text("Primary Button")
        }
        
        RoundedButton(style: .secondary, {
            
        }) {
            Text("Secondary Button")
        }
    }
    .padding()
}
