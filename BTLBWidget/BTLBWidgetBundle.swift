//
//  BTLBWidgetBundle.swift
//  BTLBWidget
//
//  Created by Martin Kim Dung-Pham on 29.11.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct BTLBWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockscreenBTLBWidget()
        LockscreenRectangularBTLBWidget()
        MediumBTLBWidget()
        SmallBTLBWidget()
        LargeBTLBWidget()
    }
}
