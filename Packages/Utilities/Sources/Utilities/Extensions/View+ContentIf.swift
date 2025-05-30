//
//  View+ContentIf.swift
//
//
//  Created by Martin Kim Dung-Pham on 31.12.23.
//

import Foundation
import SwiftUI

public extension View {
    @ViewBuilder func contentIf<Content>(_ condition: Bool, content: @escaping () -> Content) -> some View where Content : View {
        if condition {
            content()
        } else {
            EmptyView()
        }
    }
}
