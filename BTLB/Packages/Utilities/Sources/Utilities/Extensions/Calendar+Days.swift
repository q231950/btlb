//
//  Calendar+Days.swift
//  
//
//  Created by Martin Kim Dung-Pham on 01.12.22.
//

import Foundation

/// https://sarunw.com/posts/getting-number-of-days-between-two-dates/
public extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)

        return dateComponents([.day], from: fromDate, to: toDate).day!
    }
}
