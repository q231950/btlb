//
//  SiriSearchTip.swift
//  Utilities
//
//  Created by Martin Kim Dung-Pham on 16.02.25.
//

import Foundation
import TipKit

public struct SearchTip: Tip {
    public var id: String = "dev.neoneon.tipkit.search.siri"

    public init() {
    }

    public var title: Text {
        Text("Search with Siri")
    }


    public var message: Text? {
        Text("Ask Siri to perform a search to directly jump to results")
    }


    public var image: Image? {
        Image(systemName: "magnifyingglass")
    }
}
