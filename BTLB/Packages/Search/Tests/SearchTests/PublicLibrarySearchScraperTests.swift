//
//  PublicLibrarySearchScraperTests.swift
//  BTLBTests
//
//  Created by Martin Kim Dung-Pham on 27.08.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import XCTest
import Mocks
import Persistence
import TestUtilitiesCore

@testable import Search

class PublicLibrarySearchScraperTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    var library: Library!
    let bundle = Bundle(for: PublicLibrarySearchScraperTests.self)

    override func setUp() async throws {
        try await super.setUp()

        managedObjectContext = await SomeHelper().managedObjectContextStub(for: self)
        managedObjectContext.performAndWait {
            library = Library(context: managedObjectContext)
        }
    }

    func testSearchResultCount() {
        let data = TestHelper.data(resource: "search-results", type: .json, bundle: bundle)
        let searchScraper = PublicLibrarySearchScraper(data: data, library: library)
        searchScraper.parse()
        XCTAssertEqual(searchScraper.maxSearchResults, 39)
    }

    func testSearchResultZeroCount() {
        let data = TestHelper.data(resource: "search-results-zero-count", type: .json, bundle: bundle)
        let searchScraper = PublicLibrarySearchScraper(data: data, library: library)
        searchScraper.parse()
        XCTAssertEqual(searchScraper.maxSearchResults, 0)
    }

    func testSearchResultsCount() {
        let data = TestHelper.data(resource: "search-results", type: .json, bundle: bundle)
        let searchScraper = PublicLibrarySearchScraper(data: data, library: library)
        searchScraper.parse()
        XCTAssertEqual(searchScraper.searchResultInfos.count, 10)
    }

    func testSearchResults() {
        let data = TestHelper.data(resource: "search-results", type: .json, bundle: bundle)
        let searchScraper = PublicLibrarySearchScraper(data: data, library: library)
        searchScraper.parse()
        let result = searchScraper.searchResultInfos[0]
        XCTAssertEqual(result.identifier, "T017369384")
        XCTAssertEqual(result.available, true)
        XCTAssertEqual(result.title, "•<The>• Walking Man")
        XCTAssertEqual(result.imageUrl, URL(string: "https://cover.ekz.de/9781908007421.jpg"))
        XCTAssertEqual(result.title, "•<The>• Walking Man")
        XCTAssertEqual(result.number, "T017369384")
        XCTAssertEqual(result.subtitle, "Taniguchi, Jirō - Carlsen Verlag")
        XCTAssertEqual(result.ppn, "T017369384")
        XCTAssertEqual(result.format, "21 Comic.9")
        XCTAssertEqual(result.matcode, "BUE")
        XCTAssertEqual(result.matstring, "BUE")
    }

}
