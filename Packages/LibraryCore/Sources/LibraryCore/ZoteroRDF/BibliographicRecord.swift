//
//  BibliographicRecord.swift
//  LibraryCore
//

import Foundation

/// The bibliographic data of a bookmark or a search result in the shape that reference managers
/// like Zotero expect
public struct BibliographicRecord: Sendable, Equatable {

    public struct Creator: Sendable, Equatable {

        public enum Role: Sendable, Equatable, CaseIterable {
            case author
            case editor
            case translator
            case contributor
        }

        public var role: Role
        /// The family name or, for names without a given name like "Janosch", the whole name
        public var lastName: String
        public var firstName: String?

        public init(role: Role, lastName: String, firstName: String? = nil) {
            self.role = role
            self.lastName = lastName
            self.firstName = firstName
        }
    }

    public var title: String?
    public var creators: [Creator] = []
    public var publisher: String?
    public var place: String?
    /// The year of the publication, e.g. "2024"
    public var date: String?
    public var isbn: String?
    public var doi: String?
    public var language: String?
    public var numberOfPages: String?
    public var edition: String?
    public var series: String?
    public var seriesNumber: String?
    public var tags: [String] = []
    public var callNumber: String?
    public var url: String?
    public var abstract: String?
    /// The name of the library whose catalog the record is from
    public var libraryCatalog: String?
    /// Everything that has no field of its own, one "Label: value" per line
    public var extra: String?

    public init() {}
}
