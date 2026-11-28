//
//  ZoteroRDFWriter.swift
//  LibraryCore
//

import Foundation

/// Writes bibliographic records as Zotero RDF, which Zotero imports via File → Import.
///
/// The elements are the ones of Zotero's own "Zotero RDF" export translator,
/// https://github.com/zotero/translators/blob/master/Zotero%20RDF.js
public struct ZoteroRDFWriter {

    public init() {}

    public func data(for records: [BibliographicRecord]) -> Data {
        Data(string(for: records).utf8)
    }

    public func string(for records: [BibliographicRecord]) -> String {
        var lines = [
            #"<?xml version="1.0" encoding="UTF-8"?>"#,
            "<rdf:RDF",
            #" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#""#,
            #" xmlns:z="http://www.zotero.org/namespaces/export#""#,
            #" xmlns:dcterms="http://purl.org/dc/terms/""#,
            #" xmlns:dc="http://purl.org/dc/elements/1.1/""#,
            #" xmlns:bib="http://purl.org/net/biblio#""#,
            #" xmlns:foaf="http://xmlns.com/foaf/0.1/""#,
            #" xmlns:vcard="http://nwalsh.com/rdf/vCard#""#,
            #" xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/">"#,
        ]

        var usedIdentifiers = Set<String>()
        for (index, record) in records.enumerated() {
            let identifier = Self.identifier(of: record, at: index, used: usedIdentifiers)
            usedIdentifiers.insert(identifier)

            lines += Self.lines(for: record, identifier: identifier)
        }

        lines.append("</rdf:RDF>")

        return lines.joined(separator: "\n") + "\n"
    }

    /// The ISBN or URL of the record like Zotero does it, unless another record uses it already
    private static func identifier(of record: BibliographicRecord, at index: Int, used: Set<String>) -> String {
        if let isbn = record.isbn {
            let identifier = "urn:isbn:\(isbn)"
            if !used.contains(identifier) {
                return identifier
            }
        }

        if let url = record.url, !used.contains(url) {
            return url
        }

        return "#item_\(index + 1)"
    }

    private static func lines(for record: BibliographicRecord, identifier: String) -> [String] {
        var lines = [String]()
        let indent = "        "

        func element(_ name: String, _ value: String?) {
            guard let value, !value.isEmpty else { return }

            lines.append("\(indent)<\(name)>\(escaped(value))</\(name)>")
        }

        lines.append(#"    <bib:Book rdf:about="\#(escaped(identifier))">"#)
        element("z:itemType", "book")

        if record.series != nil || record.seriesNumber != nil {
            lines.append("\(indent)<dcterms:isPartOf>")
            lines.append("\(indent)    <bib:Series>")
            if let series = record.series {
                lines.append("\(indent)        <dc:title>\(escaped(series))</dc:title>")
            }
            if let seriesNumber = record.seriesNumber {
                lines.append("\(indent)        <dc:identifier>\(escaped(seriesNumber))</dc:identifier>")
            }
            lines.append("\(indent)    </bib:Series>")
            lines.append("\(indent)</dcterms:isPartOf>")
        }

        if record.publisher != nil || record.place != nil {
            lines.append("\(indent)<dc:publisher>")
            lines.append("\(indent)    <foaf:Organization>")
            if let place = record.place {
                lines.append("\(indent)        <vcard:adr>")
                lines.append("\(indent)            <vcard:Address>")
                lines.append("\(indent)               <vcard:locality>\(escaped(place))</vcard:locality>")
                lines.append("\(indent)            </vcard:Address>")
                lines.append("\(indent)        </vcard:adr>")
            }
            if let publisher = record.publisher {
                lines.append("\(indent)        <foaf:name>\(escaped(publisher))</foaf:name>")
            }
            lines.append("\(indent)    </foaf:Organization>")
            lines.append("\(indent)</dc:publisher>")
        }

        for role in BibliographicRecord.Creator.Role.allCases {
            let creators = record.creators.filter { $0.role == role }
            guard !creators.isEmpty else { continue }

            let name = elementName(for: role)
            lines.append("\(indent)<\(name)>")
            lines.append("\(indent)    <rdf:Seq>")
            for creator in creators {
                lines.append("\(indent)        <rdf:li>")
                lines.append("\(indent)            <foaf:Person>")
                lines.append("\(indent)                <foaf:surname>\(escaped(creator.lastName))</foaf:surname>")
                if let firstName = creator.firstName {
                    lines.append("\(indent)                <foaf:givenName>\(escaped(firstName))</foaf:givenName>")
                }
                lines.append("\(indent)            </foaf:Person>")
                lines.append("\(indent)        </rdf:li>")
            }
            lines.append("\(indent)    </rdf:Seq>")
            lines.append("\(indent)</\(name)>")
        }

        element("dc:title", record.title)
        element("dcterms:abstract", record.abstract)
        element("prism:edition", record.edition)
        element("dc:date", record.date)
        element("z:numPages", record.numberOfPages)
        element("z:language", record.language)
        element("z:libraryCatalog", record.libraryCatalog)
        element("dc:identifier", record.isbn.map { "ISBN \($0)" })
        element("dc:identifier", record.doi.map { "DOI \($0)" })

        if let url = record.url {
            lines.append("\(indent)<dc:identifier>")
            lines.append("\(indent)    <dcterms:URI>")
            lines.append("\(indent)       <rdf:value>\(escaped(url))</rdf:value>")
            lines.append("\(indent)    </dcterms:URI>")
            lines.append("\(indent)</dc:identifier>")
        }

        if let callNumber = record.callNumber {
            lines.append("\(indent)<dc:subject>")
            lines.append("\(indent)    <dcterms:LCC>")
            lines.append("\(indent)       <rdf:value>\(escaped(callNumber))</rdf:value>")
            lines.append("\(indent)    </dcterms:LCC>")
            lines.append("\(indent)</dc:subject>")
        }

        for tag in record.tags {
            element("dc:subject", tag)
        }

        element("dc:description", record.extra)
        lines.append("    </bib:Book>")

        return lines
    }

    /// Zotero RDF knows authors, editors and contributors from the bibliographic ontology, all
    /// other creators are in Zotero's own namespace
    private static func elementName(for role: BibliographicRecord.Creator.Role) -> String {
        switch role {
        case .author: return "bib:authors"
        case .editor: return "bib:editors"
        case .contributor: return "bib:contributors"
        case .translator: return "z:translators"
        }
    }

    static func escaped(_ text: String) -> String {
        var escaped = ""
        escaped.reserveCapacity(text.count)

        for scalar in text.unicodeScalars {
            switch scalar {
            case "&": escaped += "&amp;"
            case "<": escaped += "&lt;"
            case ">": escaped += "&gt;"
            case "\"": escaped += "&quot;"
            case "'": escaped += "&apos;"
            case "\t", "\n", "\r": escaped.unicodeScalars.append(scalar)
            // control characters are not allowed in XML 1.0
            case _ where scalar.value < 0x20 || scalar.value == 0xFFFE || scalar.value == 0xFFFF: break
            default: escaped.unicodeScalars.append(scalar)
            }
        }

        return escaped
    }
}
