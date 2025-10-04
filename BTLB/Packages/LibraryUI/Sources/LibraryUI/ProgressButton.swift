//
//  ProgressButton.swift
//  
//
//  Created by Martin Kim Dung-Pham on 25.10.22.
//

import SwiftUI
import LibraryCore

public struct ProgressButton: View {

    var animation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    @State private var isAnimating = false

    let state: ProgressButtonState
    let action: () -> Void

    public init(state: ProgressButtonState, action: @escaping () -> Void) {
        self.state = state
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Group {
                switch state {
                case .idle(let imageName):
                    Image(systemName: imageName)
                case .animating(let imageName):
                    Image(systemName: imageName)
                        .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
                        .animation(animation, value: isAnimating)
                        .onAppear { self.isAnimating = true }
                        .onDisappear { self.isAnimating = false }
                case .success(systemImageName: let imageName):
                    Image(systemName: imageName)
                        .foregroundColor(.green)
                case .failure(systemImageName: let imageName):
                    Image(systemName: imageName)
                        .foregroundColor(.red)
                }
            }
        }
        .disabled({
            if case .success = state {
                return true
            } else if case .animating = state {
                return true
            } else {
                return false
            }
        }())
    }
}

struct ProgressButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressButton(
                state: .animating(systemImageName: "arrow.triangle.2.circlepath"),
                action: {})
            .padding()

            ProgressButton(
                state: .success(systemImageName: "checkmark.circle"),
                action: {})
            .padding()

            ProgressButton(
                state: .failure(systemImageName: "xmark.circle"),
                action: {})
            .padding()
        }
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
