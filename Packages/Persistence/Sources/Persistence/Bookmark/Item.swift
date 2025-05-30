//
//  Item.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 22.03.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation
import CoreData
import LibraryCore

@objc(EDItem) extension EDItem {

    @objc public var sectionIdentifier: String {
        if let identifier = identifier, identifier.count > 0 {
            return identifier
        } else if let shelfmark = shelfmark, shelfmark.count > 0 {
            return shelfmark
        } else if let barcode = barcode, barcode.count > 0 {
            return barcode
        } else {
      //      assertionFailure("items should be uniquely identifyable")

            return UUID().uuidString
        }
    }

    @objc public var bookmarkDescription: String? {
        if let author = author, author.count > 0 {
            return author
        } else if let shelfmark = shelfmark, shelfmark.count > 0 {
            return shelfmark
        } else if let barcode = barcode, barcode.count > 0 {
            return barcode
        } else {
            return nil
        }
    }

    @objc public var type: BookmarkType {
        if loan != nil {
            return .loan
        } else {
            return .searchResult
        }
    }
}
