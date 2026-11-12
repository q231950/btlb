//
//  BibliographyFormatter.swift
//  LibraryCore
//

import Foundation

/// Writes bibliographic records as text, one short reference per record:
///
///     Trauriger Tiger
///     Neige Sinno; Michaela Meßner
///     München: dtv, 2024
///     ISBN 978-3-423-28422-6
///     Staatsbibliothek zu Berlin, 10 A 186926
///     https://stabikat.de/Record/1869120094
public struct BibliographyFormatter {

    /// The parts of a record's reference, which each text format lays out in its own way
    public struct Entry: Sendable, Equatable {
        public var title: String?
        /// The creators, the publication, the identifiers and the library, one per line
        public var lines: [String]
        public var url: String?

        public init(title: String?, lines: [String], url: String?) {
            self.title = title
            self.lines = lines
            self.url = url
        }
    }

    public init() {}

    public func entry(for record: BibliographicRecord) -> Entry {
        let creators = record.creators
            .map { creator in
                [creator.firstName, creator.lastName].compactMap { $0 }.joined(separator: " ")
            }
            .joined(separator: "; ")

        let placeAndPublisher = Self.joined([record.place, record.publisher], separator: ": ")
        let publication = Self.joined(
            [record.edition, Self.joined([placeAndPublisher, record.date], separator: ", ")],
            separator: ". "
        )

        let lines = [
            creators,
            publication,
            record.isbn.map { "ISBN \($0)" },
            record.doi.map { "DOI \($0)" },
            Self.joined([record.libraryCatalog, record.callNumber], separator: ", "),
        ]

        return Entry(
            title: record.title,
            lines: lines.compactMap { $0 }.filter { !$0.isEmpty },
            url: record.url
        )
    }

    /// The references as plain text, separated by an empty line
    public func plainText(for records: [BibliographicRecord]) -> String {
        records
            .map { record in
                let entry = entry(for: record)

                return ([entry.title] + entry.lines + [entry.url])
                    .compactMap { $0 }
                    .joined(separator: "\n")
            }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    /// The references as Markdown, each one under a heading with its title
    public func markdown(for records: [BibliographicRecord]) -> String {
        records
            .map { record in
                let entry = entry(for: record)

                var lines = entry.lines.map(Self.escapedMarkdown)
                if let url = entry.url {
                    lines.append("<\(url)>")
                }

                // two trailing spaces break a line
                let body = lines.joined(separator: "  \n")
                let heading = entry.title.map { "## \(Self.escapedMarkdown($0))" }

                return [heading, body.isEmpty ? nil : body]
                    .compactMap { $0 }
                    .joined(separator: "\n\n")
            }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    private static func joined(_ parts: [String?], separator: String) -> String? {
        let parts = parts.compactMap { $0 }.filter { !$0.isEmpty }

        return parts.isEmpty ? nil : parts.joined(separator: separator)
    }

    /// Escapes the characters that Markdown reads as markup
    static func escapedMarkdown(_ text: String) -> String {
        var escaped = ""

        for character in text {
            if #"\`*_[]<>#|"#.contains(character) {
                escaped.append("\\")
            }
            escaped.append(character)
        }

        return escaped
    }
}
