//
//  Bookmark+ZoteroRDF.swift
//  Bookmarks
//

import CoreData
import Foundation

import LibraryCore
import Persistence

extension Bookmark {

    /// The bibliographic data of the bookmark for the export to Zotero
    ///
    /// - parameter libraryName: the name of the library of the bookmark, looked up when `nil`
    func bibliographicRecord(libraryName: String? = nil) -> BibliographicRecord {
        let item = self as? EDItem

        return BibliographicRecordMapper().record(
            fields: infos.map { (label: $0.title, value: $0.value) },
            title: bookmarkTitle,
            author: bookmarkAuthor,
            isbn: item?.isbn,
            callNumber: item?.shelfmark,
            libraryCatalog: libraryName ?? item?.libraryName
        )
    }

    /// The Zotero RDF file of the bookmark
    var zoteroRDFDocument: ZoteroRDFDocument {
        ZoteroRDFDocument(name: bookmarkTitle ?? "", records: [bibliographicRecord()])
    }
}

private extension EDItem {

    var libraryName: String? {
        guard let libraryIdentifier, let managedObjectContext else { return nil }

        let fetchRequest = NSFetchRequest<Persistence.Library>(entityName: "Library")
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", libraryIdentifier)
        fetchRequest.fetchLimit = 1

        return (try? managedObjectContext.fetch(fetchRequest))?.first?.name
    }
}
