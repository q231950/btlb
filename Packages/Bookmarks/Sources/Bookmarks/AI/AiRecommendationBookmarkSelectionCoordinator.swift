//
//  AiCoordinator.swift
//  Bookmarks
//
//  Created by Martin Kim Dung-Pham on 06.06.25.
//
import SwiftUI
import ArchitectureX

import LibraryCore
import LibraryUI

@MainActor class AiRecommendationBookmarkSelectionCoordinator: @MainActor Coordinator {
    var router: Router?

    let bookmarks: [any LibraryCore.Bookmark]

    init(bookmarks: [any LibraryCore.Bookmark]) {
        self.bookmarks = bookmarks
    }

    var contentView: some View {
        AiRecommendationBookmarkSelectionCoordinatorView(bookmarks: bookmarks, onSelected: { selectedBookmarks, recommender in
            self.transition(to: AiRecommenderCoordinator(recommender: recommender, bookmarks: selectedBookmarks), style: .push)
        })
    }
}

struct AiRecommendationBookmarkSelectionCoordinatorView: View {
    @State private var selectedItems = [any Bookmark]()
    @State private var showInfo = false
    @Environment(\.recommender) var recommender

    let bookmarks: [any LibraryCore.Bookmark]
    let onSelected: ([any LibraryCore.Bookmark], _ recommender: RecommenderProtocol) -> Void

    private var recommendButton: some View {
        RoundedButton({
            onSelected(selectedItems, recommender)
        }) {
            Text("Generate Recommendations", bundle: .module)
        }
        .padding()
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    Section {
                        ForEach(bookmarks, id: \.bookmarkIdentifier) { bookmark in
                            HStack {
                                Text(bookmark.bookmarkTitle ?? "n/a")
                                Spacer()

                                if selectedItems.contains(where: { $0.bookmarkIdentifier == bookmark.bookmarkIdentifier}) {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle()) // Makes entire row tappable
                            .onTapGesture {
                                toggleSelection(for: bookmark)
                            }
                        }
                    } header: {
                        Text("Recommender Selection Description", bundle: .module)
                    }
                }
                .navigationTitle("Recommender Title".localized(bundle: .module))
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: 100) // Reserve space for the floating button
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
                .sheet(isPresented: $showInfo) {
                    AIRecommendationInfoView()
                }
                
                recommendButton
                    .disabled(selectedItems.isEmpty)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
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
    AiRecommendationBookmarkSelectionCoordinator(
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
