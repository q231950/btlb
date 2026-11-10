//
//  BibliographyFormatterTests.swift
//  LibraryCoreTests
//

import Foundation
import XCTest

import LibraryCore

final class BibliographyFormatterTests: XCTestCase {

    private let sut = BibliographyFormatter()

    private var book: BibliographicRecord {
        var record = BibliographicRecord()
        record.title = "Trauriger Tiger"
        record.creators = [
            .init(role: .author, lastName: "Sinno", firstName: "Neige"),
            .init(role: .translator, lastName: "Meßner", firstName: "Michaela"),
        ]
        record.place = "München"
        record.publisher = "dtv"
        record.date = "2024"
        record.edition = "2. Auflage"
        record.isbn = "978-3-423-28422-6"
        record.doi = "10.1000/182"
        record.callNumber = "10 A 186926"
        record.url = "https://stabikat.de/Record/1869120094"
        record.libraryCatalog = "Staatsbibliothek zu Berlin"
        record.tags = ["Autobiografie"]
        record.extra = "PPN: 1869120094"

        return record
    }

    private var titleOnly: BibliographicRecord {
        var record = BibliographicRecord()
        record.title = "Neuromancer"

        return record
    }

    // MARK: Plain text

    func testPlainText() {
        XCTAssertEqual(sut.plainText(for: [book]), """
        Trauriger Tiger
        Neige Sinno; Michaela Meßner
        2. Auflage. München: dtv, 2024
        ISBN 978-3-423-28422-6
        DOI 10.1000/182
        Staatsbibliothek zu Berlin, 10 A 186926
        https://stabikat.de/Record/1869120094
        """)
    }

    func testPlainText_separatesRecordsByAnEmptyLine() {
        XCTAssertEqual(sut.plainText(for: [titleOnly, book, titleOnly]).components(separatedBy: "\n\n").count, 3)
        XCTAssertTrue(sut.plainText(for: [titleOnly, book]).hasPrefix("Neuromancer\n\nTrauriger Tiger\n"))
    }

    func testPlainText_leavesOutWhatIsMissing() {
        var record = BibliographicRecord()
        record.title = "Neuromancer"
        record.creators = [.init(role: .author, lastName: "Janosch")]
        record.publisher = "Heyne"
        record.callNumber = "SF Gib"

        XCTAssertEqual(sut.plainText(for: [record]), "Neuromancer\nJanosch\nHeyne\nSF Gib")
    }

    func testPlainText_whenPlaceAndYearOnly() {
        var record = BibliographicRecord()
        record.place = "München"
        record.date = "1987"

        XCTAssertEqual(sut.plainText(for: [record]), "München, 1987")
    }

    func testPlainText_whenNoRecords() {
        XCTAssertEqual(sut.plainText(for: []), "")
        XCTAssertEqual(sut.plainText(for: [BibliographicRecord()]), "")
    }

    // MARK: Markdown

    func testMarkdown() {
        XCTAssertEqual(sut.markdown(for: [book, titleOnly]), [
            "## Trauriger Tiger",
            "",
            "Neige Sinno; Michaela Meßner  ",
            "2. Auflage. München: dtv, 2024  ",
            "ISBN 978-3-423-28422-6  ",
            "DOI 10.1000/182  ",
            "Staatsbibliothek zu Berlin, 10 A 186926  ",
            "<https://stabikat.de/Record/1869120094>",
            "",
            "## Neuromancer",
        ].joined(separator: "\n"))
    }

    func testMarkdown_escapesMarkup() {
        var record = BibliographicRecord()
        record.title = "C# *in* a_nutshell [2nd] <new>"
        record.publisher = "O`Reilly | Media"

        XCTAssertEqual(
            sut.markdown(for: [record]),
            "## C\\# \\*in\\* a\\_nutshell \\[2nd\\] \\<new\\>\n\nO\\`Reilly \\| Media"
        )
    }

    func testMarkdown_whenNoTitle() {
        var record = BibliographicRecord()
        record.isbn = "9783453313897"

        XCTAssertEqual(sut.markdown(for: [record]), "ISBN 9783453313897")
    }

    func testMarkdown_whenNoRecords() {
        XCTAssertEqual(sut.markdown(for: []), "")
    }

    // MARK: Entry

    func testEntry() {
        XCTAssertEqual(sut.entry(for: book), .init(
            title: "Trauriger Tiger",
            lines: [
                "Neige Sinno; Michaela Meßner",
                "2. Auflage. München: dtv, 2024",
                "ISBN 978-3-423-28422-6",
                "DOI 10.1000/182",
                "Staatsbibliothek zu Berlin, 10 A 186926",
            ],
            url: "https://stabikat.de/Record/1869120094"
        ))
    }
}
