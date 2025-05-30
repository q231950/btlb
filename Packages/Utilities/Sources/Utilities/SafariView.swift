//
//  SafariView.swift
//
//
//  Created by Martin Kim Dung-Pham on 06.12.23.
//
// Copy Pasted from https://www.danijelavrzan.com/posts/2023/03/in-app-safari-view/

import SwiftUI
import SafariServices

public struct SafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<Self>
    ) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    public func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariViewWrapper>
    ) {}
}
