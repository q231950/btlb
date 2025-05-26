//
//  TinyEntryView.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 20.01.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Utilities

struct TinyEntryView : View {

    let entry: Provider.Entry
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily

    var body: some View {
        switch entry.state {
        case .content(viewModel: let viewModel):
            switch widgetFamily {
            case .accessoryRectangular:
                TinyRectangularContentView(viewModel: viewModel)
            default:
                TinyContentView(viewModel: viewModel)
            }

        case .accountInfo(let viewModel): TinyAccountErrorView(viewModel: viewModel)
        }
    }
}

private struct TinyContentView: View {
    let viewModel: WidgetState.ContentViewModel

    var body: some View {
        VStack {
            Text(viewModel.daysUntilNextReturnDateDigits)
                .multilineTextAlignment(.trailing)
                .font(.title)
                .widgetAccentable()
            Image(systemName: "book")
                .scaleEffect(0.9)
        }
        .applyBackground()
    }
}

private struct TinyRectangularContentView: View {
    let viewModel: WidgetState.ContentViewModel

    var body: some View {
        Text(viewModel.daysUntilNextReturnDateText)
            .multilineTextAlignment(.trailing)
            .font(.largeTitle)
            .widgetAccentable()
            .applyBackground()
    }
}

private struct TinyAccountErrorView: View {
    let viewModel: WidgetState.AccountInfoViewModel
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .scaleEffect(1.2)

            Spacer()
                .frame(height: 3)

            Text(text)
                .multilineTextAlignment(.center)
                .font(.caption)
                .widgetAccentable()
        }
        .applyBackground()
    }

    private var text: String {
        let text: String
        if viewModel.accountsCount == 0 {
            // user has no accounts at all
            text = "widget lockscreen no account"
        } else {
            // user has one or more accounts but none is activated
            text = "widget lockscreen no active accounts"
        }

        return text.localized
    }

    private var imageName: String {
        let text: String
        if viewModel.accountsCount == 0 {
            // user has no accounts at all
            text = "book"
        } else {
            // user has one or more accounts but none is activated
            text = "person.badge.key"
        }

        return text.localized
    }
}
