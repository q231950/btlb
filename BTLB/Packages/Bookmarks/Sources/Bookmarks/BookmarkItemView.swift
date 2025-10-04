//
//  BookmarkItemView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 09.02.23.
//

import Foundation
import CoreData
import SwiftUI
import Persistence
import LibraryCore
import LibraryUI

public struct BookmarkItemView: View {
    // sectioned?
    @FetchRequest private var bookmark: FetchedResults<Persistence.EDItem>
    @FetchRequest private var libraries: FetchedResults<Persistence.Library>
    
    public init(_ objectId: NSManagedObjectID) {
        _bookmark = FetchRequest(
            sortDescriptors: [],
            predicate: NSPredicate(format: "SELF == %@", objectId)
        )

        _libraries = FetchRequest(sortDescriptors: [])
    }

    public var body: some View {
        ItemView(title: bookmark.first?.title ?? "",
                 subtitle1: bookmark.first?.bookmarkDescription,
                 subtitle2: libraryName(for: bookmark.first?.libraryIdentifier),
                 subtitleSystemImageName: "building.columns",
                 badgeInfo: BadgeInfo(systemImageName: bookmark.first?.type.systemImageName)
        )
    }

    private func libraryName(for identifier: String?) -> String? {
        libraries.first { $0.identifier == identifier }?.name
    }
}
