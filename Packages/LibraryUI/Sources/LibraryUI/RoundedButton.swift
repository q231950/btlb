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

    let label: () -> Content
    @Binding var loading: Bool
    let action: (() -> Void)?
    let style: RoundedButtonStyle

    @Environment(\.isEnabled) private var isEnabled: Bool

    public init(style: RoundedButtonStyle = .primary, loading: Binding<Bool> = .constant(false), _ action: (() -> Void)? = nil, @ViewBuilder _ label: @escaping () -> Content) {
        self.style = style
        _loading = loading
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Spacer()

                Group {
                    if loading {
                        loadingView
                    } else {
                        labelView
                    }
                }
                .padding()
                .opacity(isEnabled ? 1 : 0.7)

                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 15,
                                 style: .continuous)
                .fill(style == .primary ? Color(.buttonFill) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(Color.primary.opacity(loadingOrDisabled ? 0.3 : 1), lineWidth: style == .secondary ? 3 : 4)
                )
            )
        }
        .disabled(loadingOrDisabled)
    }

    private var loadingOrDisabled: Bool {
        !isEnabled || loading
    }

    @ViewBuilder private var labelView: some View {
        label()
            .bold()
            .foregroundStyle(style == .primary ? Color(.primaryButtonForeground) : Color(.secondaryButtonForeground))
    }

    @ViewBuilder private var loadingView: some View {
        ActivityIndicator(shouldAnimate: $loading)
    }
}

#Preview {
    VStack(spacing: 20) {
        RoundedButton{
            Text("Primary Button")
        }

        RoundedButton(loading: .constant(true), {
        }) {
            Text("Primary Button loading")
        }

        RoundedButton {
            Text("Primary Button disabled")
        }
        .environment(\.isEnabled, false)

        RoundedButton(style: .secondary) {
            Text("Secondary Button")
        }

        RoundedButton(style: .secondary) {
            Text("Secondary Button disabled")
        }
        .environment(\.isEnabled, false)

        RoundedButton(style: .secondary, loading: .constant(true)) {
            Text("Secondary Button loading")
        }
    }
    .padding()
}
