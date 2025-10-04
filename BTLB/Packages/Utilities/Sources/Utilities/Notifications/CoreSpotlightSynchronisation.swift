//
//  CoreSpotlightSynchronisation.swift
//
//
//  Created by Martin Kim Dung-Pham on 14.02.24.
//

import CoreData
import Foundation
import CoreSpotlight

import LibraryCore
import Persistence

public class CoreSpotlightSynchronisation: AppEventObserver {

    public var id: UUID = UUID()
    private let domainIdentifier = "Loans"
    private let dataStackProvider: DataStackProviding

    public init(dataStackProvider: DataStackProviding) {
        self.dataStackProvider = dataStackProvider
    }

    public func handle(_ change: LibraryCore.AppEventPublisher.AppEvent) async throws {
        switch change {
        case .accountActivation(_, _, let context):
            try await updateVocabulary(in: context)
        case .accountsRefreshed(_, let context):
            try await updateVocabulary(in: context)
        default: break
        }
    }

    private lazy var index = CSSearchableIndex.default()

    private func updateVocabulary(in context: NSManagedObjectContext) async throws {
        let items = await dataStackProvider.items(in: context, renewableOnly: false, fetchLimit: 1000)
        let contents = items.map {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .item)
            attributeSet.title = $0.title
            attributeSet.relatedUniqueIdentifier = $0.barcode
            attributeSet.displayName = "\($0.title)\n \($0.dueDate.formatted(.dateTime.day().month()))"

            return CSSearchableItem(uniqueIdentifier: $0.barcode,
                                    domainIdentifier: domainIdentifier,
                                    attributeSet: attributeSet)
        }

        try await index.deleteSearchableItems(withDomainIdentifiers: [domainIdentifier])

        try await index.indexSearchableItems(contents)
    }

}
