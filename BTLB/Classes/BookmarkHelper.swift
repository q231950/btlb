//
//  BookmarkHelper.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 21.03.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation
import LibraryCore

@objc class BookmarkHelper: NSObject {

    @objc static func bookmarkIdentifier(in content: [Pair]) -> String {

        var identifiers = [String]()
            identifiers.append(contentsOf: content.compactMap({ (pair) -> String? in
                if (pair.key == "PPN" || pair.key == "Barcode" || pair.key == "ISBN") {
                    return pair.value
                }
                return nil
            }))

        return identifiers.first ?? ""
    }
}
