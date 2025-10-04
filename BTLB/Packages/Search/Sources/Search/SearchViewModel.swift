//
//  SearchViewModel.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 07/01/2017.
//  Copyright © 2017 neoneon. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()

@objc class SearchViewModel : NSObject {
    let searchTerm: String
    let date: Date
    let resultsCount: Int
    
    init(searchTerm: String, date: Date, resultsCount: Int) {
        self.searchTerm = searchTerm
        self.date = date
        self.resultsCount = resultsCount
    }
    
    public func formattedDate() -> String {
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM d, H:mm:ss", options: 0, locale: NSLocale.current)
        return dateFormatter.string(from: date)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SearchViewModel else { return false }

        return object.searchTerm == searchTerm

    }

    override var hash: Int {
        return searchTerm.hashValue
    }
}
