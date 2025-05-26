//
//  SmallBTLBWidget.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 07.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Utilities

struct MediumBTLBWidget: Widget {
    let kind: String = "BTLBWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MediumEntryView(entry: entry)
        }
        .configurationDisplayName("widget configuration title".localized)
        .description("widget configuration description".localized)
        .supportedFamilies([.systemMedium])
    }
}

#if DEBUG
#Preview(as: .systemSmall, widget: {
    MediumBTLBWidget()
}, timeline: {
    TimelineEntries.entryWithContent
})
#endif
