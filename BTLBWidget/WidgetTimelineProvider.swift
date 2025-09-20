//
//  BTLBWidget.swift
//  BTLBWidget
//
//  Created by Martin Kim Dung-Pham on 29.11.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Localization
import Utilities
import LibraryCore

struct Provider: TimelineProvider {

    private let widgetSynchronisation: WidgetSynchronisation

    init(widgetSynchronisation: WidgetSynchronisation) {
        self.widgetSynchronisation = widgetSynchronisation
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), state: .content(viewModel: Self.errorContentViewModel))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {

        let widgetState = try? widgetSynchronisation.widgetState

        guard case .content(let viewModel) = widgetState else {
            completion(SimpleEntry(date: Date(), state: .content(viewModel: Self.errorContentViewModel)))
            return
        }
        completion(SimpleEntry(date: Date(), state: .content(viewModel: viewModel)))
    }

    static var errorContentViewModel: WidgetState.ContentViewModel {
        let now = Date()
        let nearFuture = Calendar.current.date(byAdding: .day, value: 23, to: now) ?? now

        return WidgetState.ContentViewModel(
            lastUpdate: Date().addingTimeInterval(-10),
            nextReturnDate: nearFuture,
            overallNumberOfLoans: 8,
            numberOfAccounts: 1,
            items: [
                Item(title: "Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
                Item(title: "Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
                Item(title: "Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
                Item(title: "Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
                Item(title: "Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
                Item(title: "Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
                Item(title: "Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep? Do Androids Dream of Electric Sheep?",
                     dueDate: .distantFuture,
                     barcode: UUID().uuidString),
            ]
        )
    }

    private func daysText(between date: Date, and currentDate: Date) -> String {
        let days = Calendar.current.numberOfDaysBetween(currentDate, and: date)

        return "\(days) \(days == 1 ? "day".localized : "days".localized)"
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let widgetState: WidgetState = try widgetSynchronisation.widgetState

            let currentDate: Date = .now

            var entries: [SimpleEntry] = []
            for hourOffset in 0 ... 2 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!

                entries.append(SimpleEntry(date: entryDate, state: widgetState))
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)

            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let state: WidgetState
}

struct LockscreenBTLBWidget: Widget {
    let kind: String = "LockscreenBTLBWidget"

    var provider: Provider {
        Provider(widgetSynchronisation: WidgetSynchronisation(dataStackProvider: BTLBWidgetViewModel().dataStackProvider))
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: provider) { entry in
            TinyEntryView(entry: entry)
        }
        .configurationDisplayName("widget configuration title".localized)
        .description("widget configuration description".localized)
        .supportedFamilies([.accessoryInline, .accessoryCircular])
    }
}

struct LockscreenRectangularBTLBWidget: Widget {
    let kind: String = "RectangularLockscreenBTLBWidget"

    var provider: Provider {
        Provider(widgetSynchronisation: WidgetSynchronisation(dataStackProvider: BTLBWidgetViewModel().dataStackProvider))
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: provider) { entry in
            TinyEntryView(entry: entry)
        }
        .configurationDisplayName("widget configuration title".localized)
        .description("widget configuration description".localized)
        .supportedFamilies([.accessoryRectangular])
    }
}

//private struct StandardAccountErrorView: View {
//    let viewModel: WidgetState.AccountInfoViewModel
//    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily
//
//    private var text: String {
//        let text: String
//        if viewModel.accountsCount == 0 {
//            // user has no accounts at all
//            switch widgetFamily {
//            case .systemSmall:
//                text = "no account"
//            default:
//                text = "no account long"
//            }
//        } else if viewModel.accountsCount == 1 && viewModel.activatedAccountsCount == 0 {
//            // user has exactly one account which is not activated
//            switch widgetFamily {
//            case .systemSmall:
//                text = "account not active"
//            default:
//                text = "account not active long"
//            }
//        } else {
//            // user has several accounts but none is activated
//            switch widgetFamily {
//            case .systemSmall:
//                text = "no active accounts"
//            default:
//                text = "no active accounts long"
//            }
//        }
//
//        return text.localized
//    }
//
//    private var padding: CGFloat {
//        switch widgetFamily {
//        case .systemSmall:
//            return 10
//        default:
//            return 20
//        }
//    }
//
//    var body: some View {
//        VStack {
//            Spacer()
//
//            Text(text.localized)
//                .font(.body)
//
//            Spacer()
//            HStack(alignment: .bottom) {
//                Spacer()
//
//                Image(systemName: "book")
//            }
//        }
//        .applyBackground()
//    }
//}

struct BTLBWidget_Previews: PreviewProvider {

    static var previews: some View {
//        TinyEntryView(entry: entryWithContent)
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
//
//        TinyEntryView(entry: entryWithContent)
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//
//        TinyEntryView(entry: entryNoAccount)
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//
//        TinyEntryView(entry: entryNoActiveAccount)
//            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
//
//        MediumEntryView(entry: entryWithContent)
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//
//        MediumEntryView(entry: entryNoAccount)
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//
//        MediumEntryView(entry: entryNoActiveAccount)
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//
//        MediumEntryView(entry: entryWithContent)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//
//        MediumEntryView(entry: entryWithContent)
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//        MediumEntryView(entry: entryNoAccount)
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//        MediumEntryView(entry: entryNoActiveAccount)
//            .previewContext(WidgetPreviewContext(family: .systemSmall))

        LargeEntryView(entry: entryWithContent)
            .previewContext(WidgetPreviewContext(family: .systemLarge))

        LargeEntryView(entry: entryNoAccount)
            .previewContext(WidgetPreviewContext(family: .systemLarge))

        LargeEntryView(entry: entryNoActiveAccount)
            .previewContext(WidgetPreviewContext(family: .systemLarge))


    }

    private static var entryNoAccount: SimpleEntry {
        SimpleEntry(date: Date(), state: .accountInfo(viewModel: WidgetState.AccountInfoViewModel(accountsCount: 0, activatedAccountsCount: 0)))
    }

    private static var entryNoActiveAccount: SimpleEntry {
        SimpleEntry(date: Date(), state: .accountInfo(viewModel: WidgetState.AccountInfoViewModel(accountsCount: 2, activatedAccountsCount: 0)))
    }

    private static var entryWithContent: SimpleEntry {
        SimpleEntry(date: Date(), state: .content(viewModel: Provider.errorContentViewModel))
    }
}

