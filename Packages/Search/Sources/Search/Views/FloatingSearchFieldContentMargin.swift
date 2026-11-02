//
//  FloatingSearchFieldContentMargin.swift
//  BTLB
//
//  Copyright © 2026 neoneon. All rights reserved.
//

import SwiftUI
import UIKit

extension View {

    /// Keeps the end of scrollable content clear of a search field that floats above the keyboard.
    ///
    /// In the iOS 26 search tab, the focused search field sits above the keyboard. SwiftUI keeps scrollable
    /// content clear of the keyboard but not of that search field, so the field covers the end of the content.
    /// This adds a bottom content margin for the space the search field takes up above the keyboard.
    func contentMarginsForFloatingSearchField() -> some View {
        modifier(FloatingSearchFieldContentMargin())
    }
}

private struct FloatingSearchFieldContentMargin: ViewModifier {

    @State private var margin: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .contentMargins(.bottom, margin)
            .background {
                FloatingSearchFieldReader(margin: $margin)
            }
    }
}

/// Measures the margin that keeps content clear of a search field floating above the keyboard.
///
/// SwiftUI doesn't tell where the search field is, so this looks up the focused text field in the window
/// whenever the keyboard changes.
private struct FloatingSearchFieldReader: UIViewRepresentable {

    @Binding var margin: CGFloat

    func makeUIView(context: Context) -> ReaderView {
        ReaderView()
    }

    func updateUIView(_ view: ReaderView, context: Context) {
        view.onMarginChange = { margin in
            if self.margin != margin {
                self.margin = margin
            }
        }
    }

    final class ReaderView: UIView {

        /// The largest distance between the keyboard and a text field that counts as floating above the keyboard.
        ///
        /// A text field that is further away, like a search field in a navigation bar, doesn't cover the end
        /// of the content.
        private static let maximumDistanceToKeyboard: CGFloat = 44

        var onMarginChange: ((CGFloat) -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)

            isUserInteractionEnabled = false

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardDidChangeFrame(_:)),
                                                   name: UIResponder.keyboardDidChangeFrameNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillHide(_:)),
                                                   name: UIResponder.keyboardWillHideNotification,
                                                   object: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc private func keyboardWillHide(_ notification: Notification) {
            onMarginChange?(0)
        }

        /// Measures once the keyboard has settled, when the search field has moved above it.
        @objc private func keyboardDidChangeFrame(_ notification: Notification) {
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            onMarginChange?(margin(forKeyboardFrame: keyboardFrame))
        }

        /// Twice the distance from the top of the keyboard to the middle of the focused text field.
        ///
        /// That covers the text field and leaves as much space above it as the system leaves between the text
        /// field and the keyboard. It is 0 if no focused text field floats above the keyboard.
        private func margin(forKeyboardFrame keyboardFrame: CGRect?) -> CGFloat {
            guard let window,
                  let keyboardFrame,
                  let screen = window.windowScene?.screen,
                  let textField = window.focusedTextField else {
                return 0
            }

            // The keyboard frame is in screen coordinates.
            let keyboardTop = window.convert(keyboardFrame, from: screen.coordinateSpace).minY
            let textFieldFrame = textField.convert(textField.bounds, to: nil)
            let distanceToKeyboard = keyboardTop - textFieldFrame.maxY

            guard keyboardFrame.height > 0,
                  keyboardTop < window.bounds.maxY,
                  (0...Self.maximumDistanceToKeyboard).contains(distanceToKeyboard) else {
                return 0
            }

            return 2 * (keyboardTop - textFieldFrame.midY)
        }
    }
}

private extension UIView {

    /// The text field in this view's hierarchy that has focus.
    var focusedTextField: UITextField? {
        if let textField = self as? UITextField, textField.isFirstResponder {
            return textField
        }

        for subview in subviews {
            if let textField = subview.focusedTextField {
                return textField
            }
        }

        return nil
    }
}
