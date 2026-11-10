//
//  ZoteroRDFDocument.swift
//  LibraryCore
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

public extension UTType {

    /// RDF/XML, declared as an imported type in the app's Info.plist so that shared files end
    /// in ".rdf"
    static let rdfXML = UTType(importedAs: "org.w3.rdf-xml", conformingTo: .xml)
}

/// A file of bibliographic records in the Zotero RDF format, to share with a Mac and import
/// there via Zotero's File → Import
public struct ZoteroRDFDocument: Transferable, Sendable, Equatable {

    /// The name of the file without its extension
    public let name: String
    public let records: [BibliographicRecord]

    public init(name: String, records: [BibliographicRecord]) {
        self.name = name
        self.records = records
    }

    public var fileName: String {
        Self.fileName(for: name)
    }

    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .rdfXML) { document in
            SentTransferredFile(try document.writeToTemporaryDirectory())
        }
    }

    /// Writes the document into a directory of its own, such that the file keeps its name
    func writeToTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ZoteroRDF", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let url = directory.appendingPathComponent(fileName)
        try ZoteroRDFWriter().data(for: records).write(to: url, options: .atomic)

        return url
    }

    /// "Paul Foot : a life in politics" → "Paul Foot - a life in politics.rdf"
    static func fileName(for name: String) -> String {
        let forbidden = CharacterSet(charactersIn: "/\\:?%*|\"<>").union(.newlines).union(.controlCharacters)
        let cleaned = name
            .components(separatedBy: forbidden)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " - ")
            .trimmingCharacters(in: CharacterSet(charactersIn: ". "))

        let base = cleaned.isEmpty ? "Zotero" : String(cleaned.prefix(80)).trimmingCharacters(in: .whitespaces)

        return "\(base).rdf"
    }
}
