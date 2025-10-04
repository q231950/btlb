//
//  Charges+Extensions.swift
//
//
//  Created by Martin Kim Dung-Pham on 21.12.23.
//

import Foundation

import LibraryCore

public extension Array where Element == any Charge {

    /// Calculates the sum of the given list of charges
    /// - Parameter charges: the charges to calculate the sum of
    /// - Returns: either a sum or nil if there are no charges or the sum is 0
    var sum: Float? {
        let sum = reduce(0) {
            $0 + $1.chargeAmount
        }

        guard sum > 0 else { return nil }

        return sum
    }
}
