//
//  TinyBTLBWidget.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 07.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

import Utilities

struct SmallBTLBWidget: Widget {
    let kind: String = "MediumBTLBWidget"

    var provider: Provider {
        Provider(widgetSynchronisation: WidgetSynchronisation(dataStackProvider: BTLBWidgetViewModel().dataStackProvider))
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: provider) { entry in
            SmallEntryView(entry: entry)
        }
        .configurationDisplayName("widget configuration title".localized)
        .description("widget configuration description".localized)
        .supportedFamilies([.systemSmall])
    }
}
