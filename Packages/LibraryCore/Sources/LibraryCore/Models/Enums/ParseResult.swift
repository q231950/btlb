//
//  ParseResult.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.11.22.
//

import Foundation

public enum ParseResult {
    case success(String)
    case failure
    case error(Error)
}
