//
//  AppRefreshingView.swift
//  More
//
//  Created by Martin Kim Dung-Pham on 03.10.24.
//
import Foundation
import SwiftUI

public struct AppRefreshingView: View {

    @State private var isAnimating = false

    public init() {
    }

    public var body: some View {
        VStack {
            Text("bɪtlɪb")

            Spacer()

            Image(systemName: "book")
                .font(.largeTitle)
                .foregroundColor(
                    .primary
                )
                .scaleEffect(
                    isAnimating ? 1 : 0.9
                )
                .animation(
                    Animation.spring(
                        duration: 2,
                        bounce: 3
                    ).repeatForever(),
                    value: isAnimating
                )
                .onAppear {
                    self.isAnimating = true
                }

            Spacer()

            Text("refreshing accounts…", bundle: .module)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }
}

#Preview {
    AppRefreshingView()
        .environment(\.locale, .init(identifier: "DE-de"))
}
