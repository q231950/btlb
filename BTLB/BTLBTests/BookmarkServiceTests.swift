//
//  BookmarkControllerTests.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 03.09.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import XCTest

import Bookmarks
import Mocks
import Persistence
import Utilities
import TestUtilities

@testable import BTLB


class BookmarkControllerTests: XCTestCase {

    var mocStub: NSManagedObjectContext!
    var loanMock: Loan?

    override func setUp() async throws {
        try await super.setUp()

        mocStub = await SomeHelper().managedObjectContextStub(for: self)
        mocStub.performAndWait {
            loanMock = Loan(context: mocStub)
            loanMock?.loanTitle = "loan title"
        }
    }

    func testBookmarks() async throws {
        throw XCTSkip()
        guard let mock = loanMock else { XCTFail(); return }
        try await setupLoanInMockContext(mocStub)
        await mocStub.perform {
            Task {
                let bookmarkService = BookmarkService(managedObjectContext: self.mocStub)
                await bookmarkService.addFavourite(forLoan: mock)
                let count = try bookmarkService.bookmarks().count
                XCTAssertEqual(count, 1)
            }
        }
    }

    func testBookmarkLoan() async throws {
        throw XCTSkip()
        guard let mock = loanMock else { XCTFail(); return }
        try await setupLoanInMockContext(mocStub)
        await mocStub.perform {
            Task {
                let bookmarkService = BookmarkService(managedObjectContext: self.mocStub)
                await bookmarkService.addFavourite(forLoan: mock)

                let favourite = mock.favourite
                XCTAssertNotNil(favourite)
                XCTAssertEqual(mock.loanAccount?.accountType, favourite?.libraryIdentifier)
                XCTAssertEqual(mock.loanTitle, favourite?.title)
                XCTAssertEqual(mock.loanSignature, favourite?.shelfmark)
                XCTAssertEqual(mock.loanBarcode, favourite?.barcode)
                XCTAssertEqual(mock.loanBarcode, favourite?.identifier)
                XCTAssertEqual(mock.infoPair?.allObjects as? [InfoPair], favourite?.infoPair?.array as? [InfoPair])
                XCTAssertTrue(mock.loanIsFavourite!.boolValue)
            }
        }
    }

    @MainActor
    func testRemoveBookmark() async throws {
        throw XCTSkip()
        guard let mock = loanMock else { XCTFail(); return }
        try await self.setupLoanInMockContext(self.mocStub)
        let controller = BookmarkService(managedObjectContext: self.mocStub)
        await controller.addFavourite(forLoan: mock)

        await controller.removeFavourite(forLoan: mock)

        mocStub.performAndWait {
            XCTAssertNil(mock.favourite, "Removing a bookmark from a loan must remove the bookmark")
            XCTAssertFalse(self.loanMock!.loanIsFavourite!.boolValue)
        }
    }

    func setupLoanInMockContext(_ moc: NSManagedObjectContext) async throws {
        guard let mock = loanMock else { XCTFail(); return }

        let account = try await DataStackProvider().newAccount()

//        account.accountType = "an account type"
        account.addToLoans(mock)
        mock.loanAccount = account
        let infoPair = InfoPair(context: moc)
        infoPair.title = "title"
        infoPair.value = "value"
        mock.infoPair = NSSet(object: infoPair)
    }
}
