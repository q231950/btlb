//
//  LargeEntryView.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 03.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Localization
import Utilities

struct LargeBTLBWidget: Widget {
    let kind: String = "LargeBTLBWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LargeEntryView(entry: entry)
        }
        .configurationDisplayName("widget configuration title".localized)
        .description("widget configuration description".localized)
        .supportedFamilies([.systemLarge, .systemExtraLarge])
    }
}

#if DEBUG
#Preview(as: .systemLarge, widget: {
    LargeBTLBWidget()
}, timeline: {
    TimelineEntries.entryNoAccount
})

enum TimelineEntries {
    static var entryNoAccount: SimpleEntry {
        SimpleEntry(date: Date(), state: .accountInfo(viewModel: WidgetState.AccountInfoViewModel(accountsCount: 0, activatedAccountsCount: 0)))
    }

    static var entryNoActiveAccount: SimpleEntry {
        SimpleEntry(date: Date(), state: .accountInfo(viewModel: WidgetState.AccountInfoViewModel(accountsCount: 2, activatedAccountsCount: 0)))
    }

    static var entryWithContent: SimpleEntry {
        SimpleEntry(date: Date(), state: .content(viewModel: Provider.errorContentViewModel))
    }
}
#endif


struct LargeEntryView : View {

    let entry: Provider.Entry

    var body: some View {
        switch entry.state {
        case .content(viewModel: let viewModel): LargeContentView(viewModel: viewModel)
        case .accountInfo(viewModel: let viewModel): AccountErrorView(viewModel: viewModel)
        }
    }
}

private struct LargeContentView: View {

    @ObservedObject var viewModel: WidgetState.ContentViewModel
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily

    var body: some View {
        VStack(alignment: .leading) {

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

            ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(item.dueDate.formatted(.dateTime.day().month())): ").bold() + Text("\(item.title) ")
                        Spacer()
                            .frame(height: 5)
                    }
                }
                .font(.footnote)
            }

            contentIf(viewModel.hasMoreItems) {
                Text("…")
            }

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
