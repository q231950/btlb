//
//  Item.swift
//
//
//  Created by Martin Kim Dung-Pham on 04.02.24.
//

import Foundation

public class Item: NSObject, Identifiable, Codable {
    public var id: String { barcode }

    public let title: String
    public let dueDate: Date
    public let barcode: String

    public init(title: String, dueDate: Date, barcode: String) {
        self.title = title
        self.dueDate = dueDate
        self.barcode = barcode
    }
}

