//
//  BibliographyExportMenu.swift
//  LibraryUI
//

import SwiftUI

import LibraryCore

/// A menu with the formats that bookmarks and search results can be exported in. Choosing a
/// format opens the share sheet with the records in that format.
public struct BibliographyExportMenu: View {

    private let name: String
    private let records: [BibliographicRecord]

    /// - parameter name: the title of what is exported, which names the share preview and the
    ///   Zotero file
    /// - parameter records: what is exported, the menu is disabled without any
    public init(name: String, records: [BibliographicRecord]) {
        self.name = name
        self.records = records
    }

    public var body: some View {
        Menu {
            ShareLink(item: BibliographyText(records: records), preview: SharePreview(name)) {
                Label {
                    Text("export format text", bundle: .module)
                } icon: {
                    Image(systemName: "textformat")
                }
            }
            .accessibilityIdentifier("export as text")

            ShareLink(item: BibliographyMarkdown(records: records), preview: SharePreview(name)) {
                Label {
                    Text(verbatim: "Markdown")
                } icon: {
                    Image(systemName: "number")
                }
            }
            .accessibilityIdentifier("export as markdown")

            let document = ZoteroRDFDocument(name: name, records: records)

            ShareLink(item: document, preview: SharePreview(document.fileName)) {
                Label {
                    Text(verbatim: "Zotero")
                } icon: {
                    Image(systemName: "books.vertical")
                }
            }
            .accessibilityIdentifier("export for zotero")
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(records.isEmpty)
        .accessibilityLabel(Text("export menu", bundle: .module))
        .accessibilityIdentifier("export")
    }
}
