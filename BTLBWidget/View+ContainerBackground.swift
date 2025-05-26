//
//  View+ContainerBackground.swift
//  BTLBWidgetExtension
//
//  Created by Martin Kim Dung-Pham on 20.01.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func applyBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                Color.primary
                    .colorInvert()
            }
        } else {
            padding()
        }
    }
}
