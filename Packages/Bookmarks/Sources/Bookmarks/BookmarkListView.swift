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
    @FetchRequest<EDItem>(
        sortDescriptors: [SortDescriptor(\.author, order: .forward),
                          SortDescriptor(\.title, order: .forward)]
    )
    private var bookmarks: FetchedResults<EDItem>
    private let coordinator: BookmarkListCoordinator<ViewModel>
    @State private var aiRecommenderEnabled = false
    @Environment(\.settingsService) private var settingsService

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
        .toolbar {
            if aiRecommenderEnabled {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.onRecommendationButtonTap(coordinator: coordinator, bookmarks: bookmarks.map { $0 } )
                    } label: {
                        Image(systemName: "sparkles")
                    }
                }
            }
        }
        .task {
            aiRecommenderEnabled = settingsService.aiRecommenderEnabled
        }
    }

    @ViewBuilder private func bookmarkList() -> some View {
        List {
            ForEach(bookmarks) { bookmark in
                Button {
                    viewModel.show(bookmark, coordinator: coordinator)
                } label: {
                    BookmarkItemView(bookmark.objectID)
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

import Combine
import CoreData
import LibraryCore
import Utilities

import ArchitectureX

class ViewModel: BookmarkListViewModelProtocol {
    var searchText: String = ""

    func show(_ bookmark: any LibraryCore.Bookmark, coordinator: any ArchitectureX.Coordinator) {
    }

    func onRecommendationButtonTap(coordinator: BookmarkListCoordinator<some BookmarkListViewModelProtocol>, bookmarks: [any LibraryCore.Bookmark]) {
    }
}

#Preview {
    DataStackProvider.shared.loadInMemory()
    let moc = DataStackProvider.shared.foregroundManagedObjectContext
    let controller = BookmarkService(managedObjectContext: moc)

    try! controller.bookmarkSearchResult(.init(library: LibraryMock(), ISBN: "nil", title: "A", author: "a", image: nil, imageURL: nil, barcode: "", content: [Pair(key: "x", value: "a")]), identifier: "123")

    try! controller.bookmarkSearchResult(.init(library: LibraryMock(), ISBN: "n", title: "B", author: "b", image: nil, imageURL: nil, barcode: "s", content: [Pair(key: "c", value: "a")]), identifier: "234")

    try! moc.save()

    let viewModel = ViewModel()
    let coordinator = BookmarkListCoordinator(viewModel: viewModel)

    return NavigationView {
        BookmarkList(viewModel: viewModel, coordinator: coordinator)
    }
    .environment(\.managedObjectContext,
                  moc)
}

public final class LibraryMock: LibraryCore.Library {

    public init() {}

    public var name: String? = "Library A"
    public var subtitle: String?

    public var baseURL: String?
    public var catalogUrl: String?

    public var identifier: String? = "Mock Library Identifier"

    public static func == (lhs: LibraryMock, rhs: LibraryMock) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
