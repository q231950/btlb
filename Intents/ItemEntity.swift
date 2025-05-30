//
//  ItemEntity.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import AppIntents
import Foundation

import LibraryCore

public final class ItemEntity: AppEntity, Renewable {

    public let title: String
    public let dueDate: Date
    public let barcode: String

    init(title: String, dueDate: Date, barcode: String) {
        self.title = title
        self.dueDate = dueDate
        self.barcode = barcode
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource("intent entity item display representation title \(title)"),
                              subtitle: "intent entity item display representation subtitle \(dueDate.formatted(.dateTime.day().month()))")
    }

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("BTLB", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) items", table: "AppIntents")
        )
    }

    public static var defaultQuery = RenewableItemEntityQuery()

    public var id: String {
        barcode
    }
}
