//
//  BibliographyText.swift
//  LibraryCore
//

import CoreTransferable
import Foundation
import UIKit
import UniformTypeIdentifiers

/// The references of bibliographic records as text to share: rich text with bold titles and
/// links for apps that take it, plain text for all others
public struct BibliographyText: Transferable, Sendable, Equatable {

    public let records: [BibliographicRecord]

    public init(records: [BibliographicRecord]) {
        self.records = records
    }

    public var plainText: String {
        BibliographyFormatter().plainText(for: records)
    }

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .rtf) { text in
            try text.richTextData()
        }
        ProxyRepresentation(exporting: \.plainText)
    }

    /// The references with their titles in bold and their URLs as links
    public var attributedText: NSAttributedString {
        let formatter = BibliographyFormatter()
        let font = UIFont.systemFont(ofSize: 14)
        let titleFont = UIFont.boldSystemFont(ofSize: 14)
        let text = NSMutableAttributedString()

        func append(_ string: String, _ attributes: [NSAttributedString.Key: Any]) {
            if text.length > 0 {
                text.append(NSAttributedString(string: "\n", attributes: [.font: font]))
            }
            text.append(NSAttributedString(string: string, attributes: attributes))
        }

        for (index, record) in records.enumerated() {
            let entry = formatter.entry(for: record)

            if index > 0, text.length > 0 {
                text.append(NSAttributedString(string: "\n", attributes: [.font: font]))
            }
            if let title = entry.title {
                append(title, [.font: titleFont])
            }
            for line in entry.lines {
                append(line, [.font: font])
            }
            if let urlString = entry.url {
                var attributes: [NSAttributedString.Key: Any] = [.font: font]
                if let url = URL(string: urlString) {
                    attributes[.link] = url
                }
                append(urlString, attributes)
            }
        }

        return text
    }

    func richTextData() throws -> Data {
        let text = attributedText

        return try text.data(
            from: NSRange(location: 0, length: text.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )
    }
}

/// The references of bibliographic records as Markdown text to share
public struct BibliographyMarkdown: Transferable, Sendable, Equatable {

    public let records: [BibliographicRecord]

    public init(records: [BibliographicRecord]) {
        self.records = records
    }

    public var markdown: String {
        BibliographyFormatter().markdown(for: records)
    }

    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.markdown)
    }
}
