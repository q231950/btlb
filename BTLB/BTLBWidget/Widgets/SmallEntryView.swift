//
//  SmallEntryView.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 07.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Localization
import Utilities

struct SmallEntryView : View {

    let entry: Provider.Entry

    var body: some View {
        switch entry.state {
        case .content(viewModel: let viewModel): SmallContentView(viewModel: viewModel)
        case .accountInfo(viewModel: let viewModel): AccountErrorView(viewModel: viewModel)
        }
    }
}

private struct SmallContentView: View {

    let viewModel: WidgetState.ContentViewModel
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily

    var body: some View {
        VStack(alignment: .leading) {

            Spacer()

            Text(viewModel.daysUntilNextReturnDateText)
                .multilineTextAlignment(.trailing)
                .font(.largeTitle)

            Text(viewModel.daysUntilNextReturnDateSubtitle(for: widgetFamily))
                .font(.callout)

            Spacer()

            HStack(alignment: .bottom) {
                switch widgetFamily {
                case .systemSmall, .accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular:
                    EmptyView()
                default:
                    VStack(alignment: .leading) {
                        Text("currentness of data".localized)
                            .fontWeight(.semibold)
                        Text(viewModel.lastUpdate, style: .offset)

                    }
                    .font(.caption)
                }

                Spacer()

                Image(systemName: "book")
            }
        }
        .applyBackground()
    }
}
