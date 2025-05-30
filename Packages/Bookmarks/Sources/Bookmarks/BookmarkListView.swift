//
//  BookmarkListView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 16.02.23.
//

import Foundation
import SwiftUI

import LibraryUI
import Localization
import Persistence

struct BookmarkList<ViewModel: BookmarkListViewModelProtocol>: View {
    @SectionedFetchRequest<String, EDItem>(
        sectionIdentifier: \.sectionIdentifier,
        sortDescriptors: [SortDescriptor(\.author, order: .reverse),
                          SortDescriptor(\.title, order: .forward)]
    )
    private var bookmarks: SectionedFetchResults<String, EDItem>
    private let coordinator: BookmarkListCoordinator<ViewModel>

    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel, coordinator: BookmarkListCoordinator<ViewModel>) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        Group {
            if bookmarks.count > 0 {
                bookmarkList()
            } else {
                if viewModel.searchText.isEmpty {
                    PlaceholderView(imageName: "bookmark", hint: "no bookmarks hint text", bundle: .module)
                        .padding()
                } else {
                    PlaceholderView(hint: "empty search result hint text", bundle: .module)
                        .padding()
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) { newValue in
            bookmarks.nsPredicate = newValue.isEmpty ? nil : FilterPredicateBuilder(text: newValue).predicate
        }
        .navigationTitle(Localization.Titles.bookmarks)
    }

    @ViewBuilder private func bookmarkList() -> some View {
        List {
            ForEach(bookmarks) { section in
                ForEach(section) { bookmark in
                    Button {
                        viewModel.show(bookmark, coordinator: coordinator)
                    } label: {
                        BookmarkItemView(bookmark.objectID)
                    }

                }
            }
        }
    }
}

struct FilterPredicateBuilder {
    let components: [String]
    init(text: String) {
        components = text.components(separatedBy: CharacterSet(arrayLiteral: " "))
    }

    public var predicate: NSPredicate {
        let componentPredicates = components.map(componentPredicate)

        return NSCompoundPredicate(andPredicateWithSubpredicates: componentPredicates)
    }

    private func componentPredicate(text: String) -> NSPredicate {
        guard !text.isEmpty else { return NSPredicate(value: true) }

        let predicates = [
            NSPredicate(format: "title CONTAINS[c] %@", text),
            NSPredicate(format: "author CONTAINS[c] %@", text),
            NSPredicate(format: "shelfmark CONTAINS[c] %@", text)
        ]

        return NSCompoundPredicate(type: .or, subpredicates: predicates)
    }
}
