//
//  MediumEntryView.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 20.01.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Localization
import Utilities

struct MediumEntryView : View {

    let entry: Provider.Entry

    var body: some View {
        switch entry.state {
        case .content(viewModel: let viewModel): MediumContentView(viewModel: viewModel)
        case .accountInfo(viewModel: let viewModel): AccountErrorView(viewModel: viewModel)
        }
    }
}

private struct MediumContentView: View {

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
                .frame(height: 10)

            Text(Localization.Widget.Text.overallNumberOfLoansText(viewModel.overallNumberOfLoans, accountsCount: viewModel.numberOfAccounts), bundle: .localization)
                .multilineTextAlignment(.trailing)
                .font(.title2)

            Spacer()

            HStack(alignment: .bottom) {
                switch widgetFamily {
                case .systemSmall, .accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular:
                    EmptyView()
                default:
                    VStack(alignment: .leading) {
                        Text("currentness of data", bundle: .localization)
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
