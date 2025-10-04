//
//  Pair.swift
//  
//
//  Created by Martin Kim Dung-Pham on 20.02.22.
//

import Foundation

@objc public class Pair: NSObject, Identifiable, Codable {
    public var id = UUID()
    @objc public let key: String
    @objc public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
