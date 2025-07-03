//
//  SearchResultDetailViewModel.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 30.03.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import LibraryCore
import Persistence
import Utilities

final class SearchResultInfoViewModel: ObservableObject {

    @Published var result: SearchResultListItemModel
    @Published var details: LibraryCore.SearchResultDescribing?
    @Published var showsAvailabilities: Bool = false
    @Published var loading: Bool = true
    @Published var bookmarkState: BookmarkState
    private let detailsProvider: SearchResultDetailsProviding
    private var coordinator: SearchResultCoordinator?
    private var loadDetailsTask: Task<Void, Never>?

    var availabilityStatus: AvailabilityStatus {
        detailsProvider.status(availabilities: details?.availability.availabilities ?? [], in: result.library)
    }

    init(coordinator: SearchResultCoordinator? = nil, result: SearchResultListItemModel, detailsProvider: SearchResultDetailsProviding) {
        self.coordinator = coordinator
        self.result = result
        self.detailsProvider = detailsProvider
        self.bookmarkState = .loading

        defer {
            Task {
                await updateBookmarkState()
            }

            loadDetailsTask = Task { @MainActor [weak self] in
                await self?.loadDetails()
                self?.loading = false
            }
        }
    }

    @MainActor func updateBookmarkState() {
        let controller = BookmarkService(managedObjectContext: DataStackProvider.shared.foregroundManagedObjectContext)
        let bookmarked = controller.hasBookmark(identifier: result.number, title: self.result.title)
        bookmarkState = .bookmarked(bookmarked)
    }

    @MainActor func toggleBookmark() {
        let controller = BookmarkService(managedObjectContext: DataStackProvider.shared.foregroundManagedObjectContext)

        do {
            if case .bookmarked(let bookmark) = bookmarkState {
                if bookmark {
                    try controller.removeBookmark(identifier: self.result.number, title: self.result.title)
                } else {
                    try controller.bookmark(content: details?.content ?? [],
                                            imageUrl: self.result.imageUrl?.absoluteString,
                                            title: self.result.title,
                                            isbn: self.result.number,
                                            image: nil,
                                            libraryIdentifier: self.result.library.identifier ?? "",
                                            identifier: self.result.number)
                }
                bookmarkState = .bookmarked(!bookmark)
            }
        } catch {
            // .. count till 10
        }
    }

    func dismiss() {
        coordinator?.dismiss()
    }

    @MainActor private func loadDetails() async {
        details = try? await detailsProvider.details(for: result.detailUrl, in: result.library)
    }

    private func isbnList(from text: String) -> [String] {
        let preprocessedText = text.replacingOccurrences(of: "-", with: "")
        let range = NSRange(preprocessedText.startIndex..<preprocessedText.endIndex, in: preprocessedText)
        let capturePattern = "\\d{13}|\\d{10}"
        let captureRegex = try! NSRegularExpression(
            pattern: capturePattern,
            options: []
        )
        let matches = captureRegex.matches(
            in: preprocessedText,
            options: [],
            range: range
        )

        var isbns = [String]()
        for match in matches {
            for rangeIndex in 0..<match.numberOfRanges {
                let matchRange = match.range(at: rangeIndex)

                if let substringRange = Range(matchRange, in: preprocessedText) {
                    let capture = String(preprocessedText[substringRange])
                    isbns.append(capture)
                }
            }
        }

        return isbns
    }
}
