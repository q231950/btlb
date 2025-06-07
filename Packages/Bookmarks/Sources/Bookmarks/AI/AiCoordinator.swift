//
//  AiCoordinator.swift
//  Bookmarks
//
//  Created by Martin Kim Dung-Pham on 06.06.25.
//
import SwiftUI
import ArchitectureX

import LibraryCore

class AiRecommenderCoordinator: Coordinator {
    var router: Router?

    let recommender: RecommenderProtocol
    let bookmarks: [any LibraryCore.Bookmark]

    init(recommender: RecommenderProtocol, bookmarks: [any LibraryCore.Bookmark]) {
        self.recommender = recommender
        self.bookmarks = bookmarks
    }

    var contentView: some View {
        AiRecommenderView(viewModel: .init(recommender, titles: bookmarks.compactMap { $0.bookmarkTitle }))
    }
}

class AiRecommenderViewModel: ObservableObject {
    let recommender: RecommenderProtocol
    let titles: [String]
    
    @Published var recommendations: [String] = []

    init(_ recommender: RecommenderProtocol, titles: [String]) {
        self.recommender = recommender
        self.titles = titles
    }
}

struct AiRecommenderView: View {

    let viewModel: AiRecommenderViewModel
    var body: some View {
        Text("Recommending…")
    }
}

class AiCoordinator: Coordinator {
    var router: Router?

    let bookmarks: [any LibraryCore.Bookmark]

    init(bookmarks: [any LibraryCore.Bookmark]) {
        self.bookmarks = bookmarks
    }

    var contentView: some View {
        AiCoordinatorView(bookmarks: bookmarks) { selectedBookmarks, recommender in
            self.transition(to: AiRecommenderCoordinator(recommender: recommender, bookmarks: selectedBookmarks), style: .push)
        }
    }
}

struct AiCoordinatorView: View {
    @State private var selectedItems = [any Bookmark]()
    @Environment(\.recommender) var recommender

    let bookmarks: [any LibraryCore.Bookmark]
    let onSelected: ([any LibraryCore.Bookmark], _ recommender: RecommenderProtocol) -> Void

    var body: some View {
        VStack {
        List {
            ForEach(bookmarks, id: \.bookmarkIdentifier) { bookmark in
                HStack {
                    Text(bookmark.bookmarkTitle ?? "n/a")
                    Spacer()

                    if selectedItems.contains(where: { $0.bookmarkIdentifier == bookmark.bookmarkIdentifier}) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.primary)
                    }
                }
                .contentShape(Rectangle()) // Makes entire row tappable
                .onTapGesture {
                    toggleSelection(for: bookmark)
                }
            }
        }

        Button {
            onSelected(selectedItems, recommender)
        } label: {
            Text("recommend for selected")
        }
    }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("✨ Recommender")
    }

    private func toggleSelection(for bookmark: any Bookmark) {
        if selectedItems.contains(where: { $0.bookmarkIdentifier == bookmark.bookmarkIdentifier}) {
            selectedItems.removeAll { b in
                b.bookmarkIdentifier == bookmark.bookmarkIdentifier
            }
        } else {
            selectedItems.insert(bookmark, at: 0)
        }
    }
}

#Preview {
    AiCoordinator(
        bookmarks: [
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock(),
            BookmarkMock()
        ]
    ).view
        .containInNavigation
}

struct BookmarkMock: Bookmark {
    let id = UUID()

    var bookmarkIdentifier: String? = UUID().uuidString

    var bookmarkTitle: String? = "Test" + UUID().uuidString

    var bookmarkAuthor: String?

    var bookmarkImageUrl: String?

    var bookmarkLibraryIdentifier: String?

    var infos: [LibraryCore.Info] = []

    static func == (lhs: BookmarkMock, rhs: BookmarkMock) -> Bool {
        lhs.bookmarkIdentifier == rhs.bookmarkIdentifier
    }


}
