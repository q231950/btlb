//
//  ActivityIndicator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 30.03.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

/// A ProgressView for older iOS versions
public struct ActivityIndicator: UIViewRepresentable {
    @Binding var shouldAnimate: Bool

    public init(shouldAnimate: Binding<Bool>) {
        _shouldAnimate = shouldAnimate
    }

    public func makeUIView(context: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        if self.shouldAnimate {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
