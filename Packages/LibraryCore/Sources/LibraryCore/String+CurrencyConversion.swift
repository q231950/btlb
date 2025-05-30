//
//  String+CurrencyConversion.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 14.10.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation

public extension String {

    func euroValue() -> Float {
        let withoutCurrencySymbol = self.trimmingCharacters(in: CharacterSet(charactersIn: "€ "))

        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .default
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "de_DE")
        numberFormatter.currencySymbol = ""

        guard let number = numberFormatter.number(from: withoutCurrencySymbol) else {
            return 0
        }

        return number.floatValue
    }
}
