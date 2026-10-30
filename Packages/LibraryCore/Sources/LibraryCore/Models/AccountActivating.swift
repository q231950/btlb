//
//  AccountActivating.swift
//  
//
//  Created by Martin Kim Dung-Pham on 04.03.23.
//

import Foundation

public protocol AccountActivating {
    @MainActor func activate(_ account: any Account) async -> ActivationState
}
