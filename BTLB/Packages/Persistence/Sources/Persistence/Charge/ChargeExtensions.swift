//
//  ChargeExtensions.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.02.23.
//

import Foundation
import LibraryCore

extension Charge: LibraryCore.Charge {

    public var chargeAmount: Float {
        amount?.floatValue ?? 0
    }

    public var reason: String? {
        chargeDescription
    }
}
