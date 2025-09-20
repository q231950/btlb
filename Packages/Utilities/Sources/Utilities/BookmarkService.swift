//
//  BookmarkService.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 17.03.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import Foundation
import UIKit
import CoreData

import LibraryCore
import Persistence

extension NSNotification.Name {
    static let bookmarkChanged = Notification.Name("bookmarkChanged")
}

@MainActor public class BookmarkService: NSObject, BookmarkServicing {

    public func isBookmarked(identifier: String?, title: String?) async throws -> Bool {
        hasBookmark(identifier: identifier, title: title)
    }

    @MainActor public func toggleBookmarked(_ loan: any LibraryCore.Loan) async throws -> Bool {

        if try await isBookmarked(identifier: loan.barcode, title: loan.title) {
            try removeBookmark(identifier: loan.barcode, title: loan.title)
            return false
        } else {
            addBookmark(for: loan)
            return true
        }
    }


    let managedObjectContext: NSManagedObjectContext

    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
    }

    public func bookmarks() throws -> [EDItem] {
        var bookmarks: [EDItem]!

        managedObjectContext.performAndWait {
            do {
                let fetchRequest = NSFetchRequest<EDItem>(entityName: "EDItem")
                fetchRequest.returnsObjectsAsFaults = false
                bookmarks = try managedObjectContext.fetch(fetchRequest)
            } catch {
                print("\(error)")
            }
        }

        return bookmarks
    }

    public func bookmark(content: [Pair], imageUrl: String?, title: String, isbn: String, image: UIImage?, libraryIdentifier: String, identifier: String) throws {
        managedObjectContext.performAndWait {
            let bookmark = EDItem(context: managedObjectContext)
            let infos = content.map({ (dict: Pair) -> InfoPair in
                let info = InfoPair(context: managedObjectContext)
                info.title = dict.key
                info.value = dict.value
                info.item = bookmark
                return info
            })

            bookmark.identifier = identifier
            bookmark.addToInfoPair(NSOrderedSet(array: infos))
            bookmark.imageURL = imageUrl
            bookmark.title = title
            bookmark.isbn = isbn
            bookmark.libraryIdentifier = libraryIdentifier

            if let image = image {
                let jpeg = image.jpegData(compressionQuality: 1)
                bookmark.imageData = jpeg
            }

            do {
                try managedObjectContext.save()
            } catch {
                print("bookmarkSearchResult: \(error)")
            }

            FeedbackController.generateBookmarkSuccessFeedback()
            NotificationCenter.default.post(name: Notification.Name.bookmarkChanged, object: nil)
        }
    }

    public func bookmarkSearchResult(_ searchResult: SearchResult, identifier: String) throws {
        managedObjectContext.performAndWait {
            let bookmark = EDItem(context: managedObjectContext)
            let infos = searchResult.content.map({ (dict: Pair) -> InfoPair in
                let info = InfoPair(context: managedObjectContext)
                info.title = dict.key
                info.value = dict.value
                info.item = bookmark
                return info

            })

            bookmark.identifier = identifier
            bookmark.addToInfoPair(NSOrderedSet(array: infos))
            bookmark.imageURL = searchResult.imageURL?.absoluteString
            bookmark.title = searchResult.title
            bookmark.isbn = searchResult.ISBN
            bookmark.author = searchResult.author
            bookmark.libraryIdentifier = searchResult.library.identifier

            if let image = searchResult.image {
                let jpeg = image.jpegData(compressionQuality: 1)
                bookmark.imageData = jpeg
            }

            do {
                try managedObjectContext.save()
            } catch {
                print("bookmarkSearchResult: \(error)")
            }

            FeedbackController.generateBookmarkSuccessFeedback()
            NotificationCenter.default.post(name: Notification.Name.bookmarkChanged, object: nil)
        }
    }

    public func removeBookmark(identifier: String?, title: String?) throws {
        if let bookmark = try bookmark(for: identifier, title: title), let managedObjectContext = bookmark.managedObjectContext {

            bookmark.loan?.loanIsFavourite = NSNumber(value: false)

            managedObjectContext.performAndWait {
                managedObjectContext.delete(bookmark)
                do {
                    try managedObjectContext.save()
                } catch {
                    print("removeBookmark: \(error)")
                }
            }

            FeedbackController.generateRemoveBookmarkSuccessFeedback()
            NotificationCenter.default.post(name: Notification.Name.bookmarkChanged, object: nil)
        }
    }

    public func hasBookmark(identifier: String?, title: String? = nil) -> Bool {
        do {
            return try bookmark(for: identifier, title: title) != nil
        } catch {
            return false
        }
    }

    func bookmark(for identifier: String?, title: String?) throws -> EDItem? {
        try bookmarks().compactMap { bookmark in
            return match(bookmark, barcode: identifier) ? bookmark : nil
        }.first
    }

    private func match(_ bookmark: EDItem, barcode: String?) -> Bool {
        var match = false
        bookmark.managedObjectContext?.performAndWait {
            match = bookmark.identifier == barcode
        }
        return match
    }
}

extension BookmarkService: BookmarksProvider {

    public func removeFavourite(forLoan loan: Persistence.Loan) async {
        guard let context = loan.managedObjectContext else { return }

        Task {
            await context.perform {
                loan.loanIsFavourite = NSNumber(booleanLiteral: false)
                if let bookmark = loan.favourite {
                    context.delete(bookmark)
                    bookmark.loan = nil
                    loan.favourite = nil
                }
                FeedbackController.generateRemoveBookmarkSuccessFeedback()

                do {
                    try context.save()
                } catch {

                }

                NotificationCenter.default.post(name: Notification.Name.bookmarkChanged, object: nil)
            }
        }
    }

    func addBookmark(for loan: any LibraryCore.Loan) {
        guard let loan = loan as? Persistence.Loan else { return }

        addFavourite(forLoan: loan)
    }

    public func addFavourite(forLoan loan: Persistence.Loan) {
        guard let context = loan.managedObjectContext else { return }

        let bookmark = EDItem(context: context)
        context.perform {
            bookmark.libraryIdentifier = loan.loanAccount?.accountType
            bookmark.title = loan.loanTitle
            bookmark.shelfmark = loan.loanSignature
            bookmark.barcode = loan.loanBarcode
            bookmark.identifier = loan.loanBarcode
            bookmark.imageURL = loan.iconUrl
            if let infoPairs = loan.infoPair {
                bookmark.infoPair = NSOrderedSet(array: infoPairs.allObjects)
            }
            loan.favourite = bookmark
            loan.bookmarked = true
            FeedbackController.generateBookmarkSuccessFeedback()

            do {
                try context.save()
            } catch {

            }
        }

        NotificationCenter.default.post(name: Notification.Name.bookmarkChanged, object: nil)
    }
}
