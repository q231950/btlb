//
//  ActivationState.swift
//  
//
//  Created by Martin Kim Dung-Pham on 25.11.22.
//

import Foundation

public enum ActivationState {
    case signInFailed
    case inactive // not signed in
    case activating // currently attempting sign in
    case activated(any Account) // signed in to library successfully
    case error // due to error (network/server down/…)
}
