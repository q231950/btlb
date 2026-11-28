//
//  BibliographicRecordMapperTests.swift
//  LibraryCoreTests
//

import Foundation
import XCTest

import LibraryCore

/// The fields are the ones of Paper's fixtures of each catalog
final class BibliographicRecordMapperTests: XCTestCase {

    private let sut = BibliographicRecordMapper()

    // MARK: OPAC

    func testRecord_whenOpac() {
        let record = sut.record(
            fields: [
                ("Titel:", "Trauriger Tiger / Neige Sinno ; aus dem Französischen von Michaela Meßner"),
                ("Person/en:", "Sinno, Neige *1977-* [VerfasserIn]Meßner, Michaela *1962-* [ÜbersetzerIn]"),
                ("Sprache/n:", "Deutsch (Sprache des Originals: Franzoesisch)"),
                ("Veröffentlichungsangabe:", "München : dtv, 2024"),
                ("Umfang:", "299 Seiten : Illustrationen"),
                ("Art des Inhalts:", "Erlebnisbericht"),
                ("Werktitel:", "Triste tigre"),
                ("ISBN:", "978-3-423-28422-6 EUR 24.00 (DE), EUR 24.70 (AT), circa CHF 32.50 (freier Preis)"),
                ("Mehr zum Titel:", "InhaltsbeschreibungInhaltsverzeichnis"),
                ("Signatur:", "10 A 186926"),
                ("Standort:", "Potsdamer Straße"),
                ("Literaturverwaltung:", "BIBTEX - ENDNOTE - RIS"),
            ],
            title: "Trauriger Tiger",
            libraryCatalog: "Staatsbibliothek zu Berlin"
        )

        XCTAssertEqual(record.title, "Trauriger Tiger")
        XCTAssertEqual(record.creators, [
            .init(role: .author, lastName: "Sinno", firstName: "Neige"),
            .init(role: .translator, lastName: "Meßner", firstName: "Michaela"),
        ])
        XCTAssertEqual(record.language, "Deutsch")
        XCTAssertEqual(record.place, "München")
        XCTAssertEqual(record.publisher, "dtv")
        XCTAssertEqual(record.date, "2024")
        XCTAssertEqual(record.numberOfPages, "299")
        XCTAssertEqual(record.isbn, "978-3-423-28422-6")
        XCTAssertEqual(record.callNumber, "10 A 186926")
        XCTAssertEqual(record.libraryCatalog, "Staatsbibliothek zu Berlin")
        XCTAssertEqual(record.extra, "Art des Inhalts: Erlebnisbericht\nWerktitel: Triste tigre")
    }

    func testRecord_whenOpacOnlineResource() {
        let record = sut.record(fields: [
            ("Titel:", "Animals and Epidemics : interspecies entanglements in historical perspective / Axel C. Hüntelmann, Christian Jaser (eds.)"),
            ("Person/en:", "Hüntelmann, Axel C. *1971-* [HerausgeberIn] ; Jaser, Christian *1975-* [HerausgeberIn]"),
            ("Veröffentlichungsangabe:", "Köln : Böhlau, [2024]"),
            ("Copyright-Datum:", "© 2024"),
            ("Umfang:", "1 Online-Ressource (307 Seiten) : Illustrationen"),
            ("Schriftenreihe:", "Tiere in der Geschichte | Animals in History ; Band 2"),
            ("ISBN:", "978-3-412-52572-9978-3-412-52572-9 digitalWeitere Ausgaben: 978-3-412-52570-5 (Druckausgabe), 3-412-52570-7 (Druckausgabe)"),
            ("Identifier:", "DOI: 10.7788/9783412525729"),
            ("Schlagwörter:", "*Tiere / Vektor, Epidemiologie / Zoonose / Epidemie*Geschichte der Medizin ; HISTORY / Social History ; Zoonosen ; Tiere"),
            ("Volltext:", "http://erf.sbb.spk-berlin.de/han/1035289881/doi.org/10.7788/9783412525729"),
        ])

        XCTAssertEqual(record.title, "Animals and Epidemics : interspecies entanglements in historical perspective")
        XCTAssertEqual(record.creators, [
            .init(role: .editor, lastName: "Hüntelmann", firstName: "Axel C."),
            .init(role: .editor, lastName: "Jaser", firstName: "Christian"),
        ])
        XCTAssertEqual(record.place, "Köln")
        XCTAssertEqual(record.publisher, "Böhlau")
        XCTAssertEqual(record.date, "2024")
        XCTAssertEqual(record.numberOfPages, "307")
        XCTAssertEqual(record.series, "Tiere in der Geschichte | Animals in History")
        XCTAssertEqual(record.seriesNumber, "Band 2")
        XCTAssertEqual(record.isbn, "978-3-412-52572-9")
        XCTAssertEqual(record.doi, "10.7788/9783412525729")
        XCTAssertEqual(record.tags, [
            "Tiere", "Vektor, Epidemiologie", "Zoonose", "Epidemie", "Geschichte der Medizin",
            "HISTORY", "Social History", "Zoonosen",
        ])
        XCTAssertEqual(record.url, "http://erf.sbb.spk-berlin.de/han/1035289881/doi.org/10.7788/9783412525729")
        XCTAssertEqual(record.extra, "Copyright-Datum: © 2024")
    }

    func testRecord_whenOpacKeywordsHoldLifeDates() {
        let record = sut.record(fields: [
            ("Schlagwörter:", "*Foot, Paul *1937-2004* / Großbritannien / Journalismus*Foot, Paul -- 1937-2004 -- DLC"),
        ])

        XCTAssertEqual(record.tags, ["Foot, Paul", "Großbritannien", "Journalismus", "Foot, Paul -- 1937-2004 -- DLC"])
    }

    func testRecord_whenPersonHasNoGivenNameAndTwoRoles() {
        let record = sut.record(fields: [("Person/en:", "Janosch *1931-* [VerfasserIn] [KünstlerIn]")])

        XCTAssertEqual(record.creators, [.init(role: .author, lastName: "Janosch")])
    }

    func testRecord_whenPlaceIsUnknown() {
        let record = sut.record(fields: [
            ("Veröffentlichungsangabe:", "[Erscheinungsort nicht ermittelbar] : Taylor & Francis, 2023"),
        ])

        XCTAssertNil(record.place)
        XCTAssertEqual(record.publisher, "Taylor & Francis")
        XCTAssertEqual(record.date, "2023")
    }

    func testRecord_whenSeveralPlaces() {
        let record = sut.record(fields: [("Veröffentlichungsangabe:", "London ; New York : Verso, 2024")])

        XCTAssertEqual(record.place, "London ; New York")
        XCTAssertEqual(record.publisher, "Verso")
        XCTAssertEqual(record.date, "2024")
    }

    func testRecord_whenExtentHasRomanPages() {
        let record = sut.record(fields: [("Umfang:", "vi, 371 pages")])

        XCTAssertEqual(record.numberOfPages, "371")
        XCTAssertNil(record.extra)
    }

    func testRecord_whenExtentHasNoPages() {
        let record = sut.record(fields: [("Umfang:", "1 CD (74 min)")])

        XCTAssertNil(record.numberOfPages)
        XCTAssertEqual(record.extra, "Umfang: 1 CD (74 min)")
    }

    // MARK: K10plus

    func testRecord_whenK10plus() {
        let record = sut.record(
            fields: [
                ("Titel", "Trauriger Tiger / Neige Sinno ; aus dem Französischen von Michaela Meßner"),
                ("Verfasser", "Sinno, Neige"),
                ("Weitere Personen", "Meßner, Michaela; Mustermann, Erika"),
                ("Ausgabe", "2. Auflage"),
                ("Veröffentlicht", "München : dtv, 2024"),
                ("Umfang", "299 Seiten"),
                ("ISBN", "9783423284226, 3423284226"),
                ("Sprache", "ger"),
                ("Schlagwörter", "Sexueller Missbrauch; Autobiografie"),
                ("Signatur", "10 A 186926"),
                ("PPN", "1869120094"),
                ("Inhaltsverzeichnis", "https://www.gbv.de/dms/toc.pdf"),
                ("DOI", "https://doi.org/10.1000/182"),
                ("Katalog", "https://stabikat.de/Record/1869120094"),
            ]
        )

        XCTAssertEqual(record.title, "Trauriger Tiger")
        XCTAssertEqual(record.creators, [
            .init(role: .author, lastName: "Sinno", firstName: "Neige"),
            .init(role: .contributor, lastName: "Meßner", firstName: "Michaela"),
            .init(role: .contributor, lastName: "Mustermann", firstName: "Erika"),
        ])
        XCTAssertEqual(record.edition, "2. Auflage")
        XCTAssertEqual(record.place, "München")
        XCTAssertEqual(record.publisher, "dtv")
        XCTAssertEqual(record.date, "2024")
        XCTAssertEqual(record.numberOfPages, "299")
        XCTAssertEqual(record.isbn, "9783423284226")
        XCTAssertEqual(record.language, "ger")
        XCTAssertEqual(record.tags, ["Sexueller Missbrauch", "Autobiografie"])
        XCTAssertEqual(record.callNumber, "10 A 186926")
        XCTAssertEqual(record.doi, "10.1000/182")
        XCTAssertEqual(record.url, "https://stabikat.de/Record/1869120094")
        XCTAssertEqual(record.extra, "PPN: 1869120094\nInhaltsverzeichnis: https://www.gbv.de/dms/toc.pdf")
    }

    func testRecord_prefersCatalogPageOverFullText() {
        let record = sut.record(fields: [
            ("Volltext", "https://example.com/fulltext"),
            ("Katalog", "https://stabikat.de/Record/1"),
        ])

        XCTAssertEqual(record.url, "https://stabikat.de/Record/1")
    }

    // MARK: Bücherhallen Hamburg

    func testRecord_whenHamburgPublic() {
        let record = sut.record(fields: [
            ("Titel:", "Triceratops, T-Rex, Supersaurus : die Welt der Dinosaurier / Virginie Aladjidi & Emmanuelle Tchoukriel"),
            ("Originaltitel:", "Inventaire illustré des dinosaures"),
            ("Person(en):", "Aladjidi, Virginie [Verfasser*in] ; Tchoukriel, Emmanuelle [Illustration] ; Panzacchi, Cornelia [Übersetzung]"),
            ("Organisation(en):", "Gebrüder Gerstenberg [Verlag]"),
            ("Sprache:", "Deutsch"),
            ("Umfang:", "circa 64 Seiten Tafeln : Illustrationen ; 31 cm"),
            ("Erschienen:", "Hildesheim : Gerstenberg Verlag, 2022"),
            ("ISBN/Preis:", "978-3-8369-6159-2 Festeinband : EUR 16.00 (DE), EUR 16.50 (AT), CHF 21.50 (freier Preis)"),
            ("Schlagwörter:", "Fossil ; Reptilien ; Vor- und Frühgeschichte ; Kindersachbuch"),
            ("Link(s):", "Inhaltsverzeichnis"),
            ("Signatur:", "Kinder > Sachmedien > Tiere Dinosaurier"),
            ("Inhalt:", "Paläontologisch interessierte Kinder erfahren viel Wissenswertes."),
        ])

        XCTAssertEqual(record.title, "Triceratops, T-Rex, Supersaurus : die Welt der Dinosaurier")
        XCTAssertEqual(record.creators, [
            .init(role: .author, lastName: "Aladjidi", firstName: "Virginie"),
            .init(role: .contributor, lastName: "Tchoukriel", firstName: "Emmanuelle"),
            .init(role: .translator, lastName: "Panzacchi", firstName: "Cornelia"),
        ])
        XCTAssertEqual(record.language, "Deutsch")
        XCTAssertEqual(record.numberOfPages, "64")
        XCTAssertEqual(record.place, "Hildesheim")
        XCTAssertEqual(record.publisher, "Gerstenberg Verlag")
        XCTAssertEqual(record.date, "2022")
        XCTAssertEqual(record.isbn, "978-3-8369-6159-2")
        XCTAssertEqual(record.tags, ["Fossil", "Reptilien", "Vor- und Frühgeschichte", "Kindersachbuch"])
        XCTAssertEqual(record.callNumber, "Kinder > Sachmedien > Tiere Dinosaurier")
        XCTAssertEqual(record.abstract, "Paläontologisch interessierte Kinder erfahren viel Wissenswertes.")
        XCTAssertEqual(
            record.extra,
            "Originaltitel: Inventaire illustré des dinosaures\nOrganisation(en): Gebrüder Gerstenberg [Verlag]"
        )
    }

    func testRecord_whenYearIsUncertainAndPlaceHasAComma() {
        let record = sut.record(fields: [
            ("Erschienen:", "Rheinbreitbach, Deutschland : Ullmann Medien GmbH, 2022?"),
        ])

        XCTAssertEqual(record.place, "Rheinbreitbach, Deutschland")
        XCTAssertEqual(record.publisher, "Ullmann Medien GmbH")
        XCTAssertEqual(record.date, "2022")
    }

    // MARK: Bookmarks of older versions

    func testRecord_whenLegacyLabels() {
        let record = sut.record(fields: [
            ("data titel-lang", "Neuromancer / William Gibson"),
            ("data personen", "Gibson, William [Verfasser]"),
            ("data erschienen", "München : Heyne, 1987"),
            ("data isbn-ean", "3-453-31389-5"),
            ("data sprache", "Deutsch"),
            ("data umfang", "363 S."),
            ("data schlagwoerter", "Cyberpunk"),
            ("data signatur", "SF Gib"),
            ("data preis", "DM 9.80"),
        ])

        XCTAssertEqual(record.title, "Neuromancer")
        XCTAssertEqual(record.creators, [.init(role: .author, lastName: "Gibson", firstName: "William")])
        XCTAssertEqual(record.place, "München")
        XCTAssertEqual(record.publisher, "Heyne")
        XCTAssertEqual(record.date, "1987")
        XCTAssertEqual(record.isbn, "3-453-31389-5")
        XCTAssertEqual(record.language, "Deutsch")
        XCTAssertEqual(record.numberOfPages, "363")
        XCTAssertEqual(record.tags, ["Cyberpunk"])
        XCTAssertEqual(record.callNumber, "SF Gib")
        XCTAssertEqual(record.extra, "Preis: DM 9.80")
    }

    // MARK: Fallbacks

    func testRecord_usesFallbacks_whenNoFields() {
        let record = sut.record(
            fields: [],
            title: "Neuromancer",
            author: "Gibson, William",
            isbn: "9783453313897",
            callNumber: "SF Gib"
        )

        XCTAssertEqual(record.title, "Neuromancer")
        XCTAssertEqual(record.creators, [.init(role: .author, lastName: "Gibson", firstName: "William")])
        XCTAssertEqual(record.isbn, "9783453313897")
        XCTAssertEqual(record.callNumber, "SF Gib")
        XCTAssertNil(record.extra)
    }

    func testRecord_prefersFieldsOverFallbacks() {
        let record = sut.record(
            fields: [
                ("Titel:", "Neuromancer : Roman / William Gibson"),
                ("Person/en:", "Gibson, William [VerfasserIn]"),
                ("ISBN:", "978-3-453-31389-7"),
                ("Signatur:", "SF Gib"),
            ],
            title: "Neuromancer",
            author: "Somebody Else",
            isbn: "9780000000000",
            callNumber: "X 1"
        )

        XCTAssertEqual(record.title, "Neuromancer : Roman")
        XCTAssertEqual(record.creators, [.init(role: .author, lastName: "Gibson", firstName: "William")])
        XCTAssertEqual(record.isbn, "978-3-453-31389-7")
        XCTAssertEqual(record.callNumber, "SF Gib")
    }

    func testRecord_ignoresFallbackIsbn_whenItIsAnItemNumber() {
        let record = sut.record(fields: [], title: "Neuromancer", isbn: "T020861691")

        XCTAssertNil(record.isbn)
    }

    func testRecord_skipsEmptyLabelsAndValues() {
        let record = sut.record(fields: [("", "Tiere Dinosaurier"), ("Anmerkung:", "  ")])

        XCTAssertEqual(record, BibliographicRecord())
    }
}
