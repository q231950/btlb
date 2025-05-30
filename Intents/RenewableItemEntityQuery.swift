//
//  ItemEntityQuery.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import AppIntents
import Foundation

import Persistence

public struct RenewableItemEntityQuery: EntityQuery {

    public init() {}

    public func entities(for identifiers: [ItemEntity.ID]) async throws -> [ItemEntity] {
        let items = await DataStackProvider.shared.items(in: DataStackProvider.shared.foregroundManagedObjectContext, 
                                                         renewableOnly: true,
                                                         fetchLimit: 1000)
        return items.filter {
            identifiers.contains($0.barcode)
        }.map({ item in
            ItemEntity(title: item.title,
                       dueDate: item.dueDate,
                       barcode: item.barcode)
        })
    }

    public func suggestedEntities() async throws -> [ItemEntity] {
        let items = await DataStackProvider.shared.items(in: DataStackProvider.shared.foregroundManagedObjectContext,
                                                         renewableOnly: true,
                                                         fetchLimit: 1000)

        return items.compactMap { item in
            ItemEntity(title: item.title, dueDate: item.dueDate, barcode: item.barcode)
        }
    }
}
