//
//  Localization.swift
//
//
//  Created by Martin Kim Dung-Pham on 22.01.24.
//

import Foundation
import SwiftUI

import Localization
import Utilities

extension Localization {

    enum Detail {
        public static let renewalConfirmationTitle: String = localized("loan detail renewal confirmation title")
        public static let renewalConfirmationRenewButtonTitle: String = localized("loan detail renewal confirmation renew button title")
        public static let renewalConfirmationCancelButtonTitle: String = localized("loan detail renewal confirmation cancel button title")
    }

    static func localized(_ value: String.LocalizationValue) -> String {
        localized(value, in: .module)
    }
}
