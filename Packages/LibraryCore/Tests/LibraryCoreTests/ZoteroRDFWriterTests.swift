//
//  ZoteroRDFWriterTests.swift
//  LibraryCoreTests
//

import Foundation
import XCTest

import LibraryCore

final class ZoteroRDFWriterTests: XCTestCase {

    private let sut = ZoteroRDFWriter()

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
        record.isbn = "978-3-423-28422-6"
        record.language = "Deutsch"
        record.numberOfPages = "299"
        record.edition = "2. Auflage"
        record.series = "dtv Literatur"
        record.seriesNumber = "Band 2"
        record.tags = ["Autobiografie", "Missbrauch"]
        record.callNumber = "10 A 186926"
        record.url = "https://stabikat.de/Record/1869120094"
        record.abstract = "Ein Bericht."
        record.libraryCatalog = "Staatsbibliothek zu Berlin"
        record.extra = "Werktitel: Triste tigre\nPPN: 1869120094"

        return record
    }

    func testString_writesAllFieldsLikeZotero() {
        let expected = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rdf:RDF
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:z="http://www.zotero.org/namespaces/export#"
         xmlns:dcterms="http://purl.org/dc/terms/"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:bib="http://purl.org/net/biblio#"
         xmlns:foaf="http://xmlns.com/foaf/0.1/"
         xmlns:vcard="http://nwalsh.com/rdf/vCard#"
         xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/">
            <bib:Book rdf:about="urn:isbn:978-3-423-28422-6">
                <z:itemType>book</z:itemType>
                <dcterms:isPartOf>
                    <bib:Series>
                        <dc:title>dtv Literatur</dc:title>
                        <dc:identifier>Band 2</dc:identifier>
                    </bib:Series>
                </dcterms:isPartOf>
                <dc:publisher>
                    <foaf:Organization>
                        <vcard:adr>
                            <vcard:Address>
                               <vcard:locality>München</vcard:locality>
                            </vcard:Address>
                        </vcard:adr>
                        <foaf:name>dtv</foaf:name>
                    </foaf:Organization>
                </dc:publisher>
                <bib:authors>
                    <rdf:Seq>
                        <rdf:li>
                            <foaf:Person>
                                <foaf:surname>Sinno</foaf:surname>
                                <foaf:givenName>Neige</foaf:givenName>
                            </foaf:Person>
                        </rdf:li>
                    </rdf:Seq>
                </bib:authors>
                <z:translators>
                    <rdf:Seq>
                        <rdf:li>
                            <foaf:Person>
                                <foaf:surname>Meßner</foaf:surname>
                                <foaf:givenName>Michaela</foaf:givenName>
                            </foaf:Person>
                        </rdf:li>
                    </rdf:Seq>
                </z:translators>
                <dc:title>Trauriger Tiger</dc:title>
                <dcterms:abstract>Ein Bericht.</dcterms:abstract>
                <prism:edition>2. Auflage</prism:edition>
                <dc:date>2024</dc:date>
                <z:numPages>299</z:numPages>
                <z:language>Deutsch</z:language>
                <z:libraryCatalog>Staatsbibliothek zu Berlin</z:libraryCatalog>
                <dc:identifier>ISBN 978-3-423-28422-6</dc:identifier>
                <dc:identifier>
                    <dcterms:URI>
                       <rdf:value>https://stabikat.de/Record/1869120094</rdf:value>
                    </dcterms:URI>
                </dc:identifier>
                <dc:subject>
                    <dcterms:LCC>
                       <rdf:value>10 A 186926</rdf:value>
                    </dcterms:LCC>
                </dc:subject>
                <dc:subject>Autobiografie</dc:subject>
                <dc:subject>Missbrauch</dc:subject>
                <dc:description>Werktitel: Triste tigre
        PPN: 1869120094</dc:description>
            </bib:Book>
        </rdf:RDF>

        """

        XCTAssertEqual(sut.string(for: [book]), expected)
    }

    func testString_whenNoRecords() {
        let string = sut.string(for: [])

        XCTAssertTrue(string.hasPrefix(#"<?xml version="1.0" encoding="UTF-8"?>"#))
        XCTAssertTrue(string.hasSuffix("</rdf:RDF>\n"))
        XCTAssertFalse(string.contains("bib:Book"))
    }

    func testString_whenRecordHasATitleOnly() {
        var record = BibliographicRecord()
        record.title = "Neuromancer"

        let string = sut.string(for: [record])

        XCTAssertTrue(string.contains("""
            <bib:Book rdf:about="#item_1">
                <z:itemType>book</z:itemType>
                <dc:title>Neuromancer</dc:title>
            </bib:Book>
        """))
    }

    func testString_escapesMarkup() {
        var record = BibliographicRecord()
        record.title = "Tom & Jerry <\"the\" 'best'>"
        record.url = "https://example.com/?a=1&b=2"
        record.extra = "bell\u{07}"

        let string = sut.string(for: [record])

        XCTAssertTrue(string.contains("<dc:title>Tom &amp; Jerry &lt;&quot;the&quot; &apos;best&apos;&gt;</dc:title>"))
        XCTAssertTrue(string.contains(#"rdf:about="https://example.com/?a=1&amp;b=2""#))
        XCTAssertTrue(string.contains("<dc:description>bell</dc:description>"))
    }

    func testString_givesEachRecordItsOwnIdentifier() {
        var first = BibliographicRecord()
        first.title = "First copy"
        first.isbn = "9783423284226"

        var second = first
        second.title = "Second copy"

        var third = BibliographicRecord()
        third.title = "No ISBN"

        let string = sut.string(for: [first, second, third])

        XCTAssertTrue(string.contains(#"<bib:Book rdf:about="urn:isbn:9783423284226">"#))
        XCTAssertTrue(string.contains(##"<bib:Book rdf:about="#item_2">"##))
        XCTAssertTrue(string.contains(##"<bib:Book rdf:about="#item_3">"##))
    }

    func testString_groupsCreatorsByRole() {
        var record = BibliographicRecord()
        record.creators = [
            .init(role: .editor, lastName: "Jaser", firstName: "Christian"),
            .init(role: .contributor, lastName: "Janosch"),
            .init(role: .editor, lastName: "Roscher", firstName: "Mieke"),
        ]

        let string = sut.string(for: [record])

        XCTAssertEqual(string.components(separatedBy: "<bib:editors>").count, 2)
        XCTAssertEqual(string.components(separatedBy: "<bib:contributors>").count, 2)
        XCTAssertTrue(string.contains("<foaf:surname>Janosch</foaf:surname>\n                    </foaf:Person>"))
    }

    func testData_isUTF8() {
        let data = sut.data(for: [book])

        XCTAssertEqual(String(data: data, encoding: .utf8), sut.string(for: [book]))
    }
}
