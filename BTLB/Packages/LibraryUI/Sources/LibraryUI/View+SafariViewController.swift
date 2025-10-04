//
//  View+SafariViewController.swift
//  LibraryUI
//
//  Created by Martin Kim Dung-Pham on 19.01.25.
//

import Foundation
import SwiftUI
import SafariServices

/// https://www.avanderlee.com/swiftui/sfsafariviewcontroller-open-webpages-in-app/
struct SFSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.configuration.entersReaderIfAvailable = true
        vc.configuration.barCollapsingEnabled = true
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
        // No need to do anything here
    }
}

/// Monitors the `openURL` environment variable and handles them in-app instead of via
/// the external web browser.
private struct SafariViewControllerViewModifier: ViewModifier {
    @State private var urlToOpen: URL?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                /// Catch any URLs that are about to be opened in an external browser.
                /// Instead, handle them here and store the URL to reopen in our sheet.
                urlToOpen = url
                return .handled
            })
            .sheet(isPresented: $urlToOpen.mappedToBool(), onDismiss: {
                urlToOpen = nil
            }, content: {
                SFSafariView(url: urlToOpen!)
            })
    }
}

extension Binding where Value == Bool {
    init(binding: Binding<(some Any)?>) {
        self.init(
            get: {
                binding.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }

                // We only handle `false` booleans to set our optional to `nil`
                // as we can't handle `true` for restoring the previous value.
                binding.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    /// Maps an optional binding to a `Binding<Bool>`.
    /// This can be used to, for example, use an `Error?` object to decide whether or not to show an
    /// alert, without needing to rely on a separately handled `Binding<Bool>`.
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(binding: self)
    }
}

extension View {
    /// Monitor the `openURL` environment variable and handle them in-app instead of via
    /// the external web browser.
    /// Uses the `SafariViewWrapper` which will present the URL in a `SFSafariViewController`.
    func handleOpenURLInApp() -> some View {
        modifier(SafariViewControllerViewModifier())
    }
}
