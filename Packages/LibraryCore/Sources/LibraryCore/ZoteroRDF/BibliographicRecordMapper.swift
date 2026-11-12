//
//  BibliographicRecordMapper.swift
//  LibraryCore
//

import Foundation

/// Creates a `BibliographicRecord` from the labelled values that the library catalogs show for a
/// title.
///
/// The labels and the shape of the values differ per catalog:
/// - OPAC (most libraries): "Person/en:", "Veröffentlichungsangabe:", "Sprache/n:", …
/// - K10plus (Staatsbibliothek zu Berlin): "Verfasser", "Weitere Personen", "Veröffentlicht", …
/// - Bücherhallen Hamburg: "Person(en):", "Erschienen:", "ISBN/Preis:", …
/// - bookmarks of older versions: "data personen", "data erschienen", "data isbn-ean", …
public struct BibliographicRecordMapper {

    public typealias Field = (label: String, value: String)

    public init() {}

    /// - parameter fields: the labelled values of the title in the order the catalog shows them
    /// - parameter title: used when no field holds a title
    /// - parameter author: used when no field holds a person, e.g. "Sinno, Neige"
    /// - parameter isbn: used when no field holds an ISBN, ignored unless it looks like an ISBN
    /// - parameter callNumber: used when no field holds a call number
    /// - parameter libraryCatalog: the name of the library whose catalog the title is from
    public func record(
        fields: [Field],
        title: String? = nil,
        author: String? = nil,
        isbn: String? = nil,
        callNumber: String? = nil,
        libraryCatalog: String? = nil
    ) -> BibliographicRecord {
        var record = BibliographicRecord()
        var extra = [String]()
        var fullTextUrl: String?

        for field in fields {
            let label = Self.normalized(label: field.label)
            let value = field.value.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !value.isEmpty, !label.isEmpty, !Self.ignoredLabels.contains(label) else { continue }

            switch label {
            case "titel", "titel-lang", "title":
                record.title = record.title ?? Self.title(from: value)
            case "verfasser", "main author", "author":
                record.creators += Self.creators(from: value, defaultRole: .author)
            case "weitere personen", "other authors":
                record.creators += Self.creators(from: value, defaultRole: .contributor)
            case "person/en", "person(en)", "personen":
                record.creators += Self.creators(from: value, defaultRole: .author)
            case "veröffentlichungsangabe", "veröffentlicht", "erschienen", "published":
                guard record.publisher == nil, record.place == nil, record.date == nil else {
                    extra.append(Self.extraLine(label: field.label, value: value))
                    continue
                }
                let publication = Self.publication(from: value)
                record.place = publication.place
                record.publisher = publication.publisher
                record.date = publication.date
            case "isbn", "isbn/preis", "isbn-ean":
                if let found = Self.isbn(in: value), record.isbn == nil {
                    record.isbn = found
                } else {
                    extra.append(Self.extraLine(label: field.label, value: value))
                }
            case "sprache", "sprache/n", "language":
                record.language = record.language ?? Self.language(from: value)
            case "umfang":
                if let pages = Self.numberOfPages(in: value), record.numberOfPages == nil {
                    record.numberOfPages = pages
                } else {
                    extra.append(Self.extraLine(label: field.label, value: value))
                }
            case "ausgabe", "edition":
                record.edition = record.edition ?? value
            case "schriftenreihe", "reihe", "series":
                guard record.series == nil else {
                    extra.append(Self.extraLine(label: field.label, value: value))
                    continue
                }
                let series = Self.series(from: value)
                record.series = series.title
                record.seriesNumber = series.number
            case "schlagwörter", "schlagwoerter":
                for tag in Self.tags(from: value) where !record.tags.contains(tag) {
                    record.tags.append(tag)
                }
            case "signatur", "call number":
                record.callNumber = record.callNumber ?? value
            case "inhalt", "summary":
                record.abstract = record.abstract ?? value
            case "katalog":
                record.url = value
            case "volltext":
                fullTextUrl = fullTextUrl ?? value
            case "doi":
                record.doi = record.doi ?? Self.doi(from: value)
            case "identifier" where value.uppercased().hasPrefix("DOI"):
                record.doi = record.doi ?? Self.doi(from: value)
            default:
                extra.append(Self.extraLine(label: field.label, value: value))
            }
        }

        record.title = record.title ?? title?.trimmedOrNil
        record.url = record.url ?? fullTextUrl
        record.callNumber = record.callNumber ?? callNumber?.trimmedOrNil
        record.libraryCatalog = libraryCatalog?.trimmedOrNil

        if record.creators.isEmpty, let author = author?.trimmedOrNil {
            record.creators = Self.creators(from: author, defaultRole: .author)
        }

        if record.isbn == nil, let isbn {
            record.isbn = Self.isbn(in: isbn)
        }

        record.extra = extra.isEmpty ? nil : extra.joined(separator: "\n")

        return record
    }
}

// MARK: Labels

extension BibliographicRecordMapper {

    /// Labels whose values are of no use in a reference manager, like the location of a copy
    static let ignoredLabels: Set<String> = [
        "standort",
        "literaturverwaltung",
        "mehr zum titel",
        "link(s)",
        "links",
        "format",
        "anschaffungsvorschlag",
    ]

    /// "Person/en:" → "person/en", "data erschienen" → "erschienen"
    static func normalized(label: String) -> String {
        var label = label.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if label.hasPrefix("data ") {
            label.removeFirst("data ".count)
        }
        while label.hasSuffix(":") {
            label.removeLast()
        }

        return label.trimmingCharacters(in: .whitespaces)
    }

    /// "Art des Inhalts:" + "Biografie" → "Art des Inhalts: Biografie"
    static func extraLine(label: String, value: String) -> String {
        var label = label.trimmingCharacters(in: .whitespacesAndNewlines)

        if label.lowercased().hasPrefix("data ") {
            label.removeFirst("data ".count)
            label = label.prefix(1).uppercased() + label.dropFirst()
        }
        while label.hasSuffix(":") {
            label.removeLast()
        }

        let value = value.replacingOccurrences(of: "\n", with: " ")

        return "\(label): \(value)"
    }
}

// MARK: Values

extension BibliographicRecordMapper {

    /// The title without the statement of responsibility,
    /// "Trauriger Tiger / Neige Sinno ; aus dem Französischen von …" → "Trauriger Tiger"
    static func title(from value: String) -> String? {
        let title = value.range(of: " / ").map { String(value[..<$0.lowerBound]) } ?? value

        return title.trimmedOrNil
    }

    /// The persons of values like
    /// - "Aladjidi, Virginie [Verfasser*in] ; Tchoukriel, Emmanuelle [Illustration]"
    /// - "Sinno, Neige *1977-* [VerfasserIn]Meßner, Michaela *1962-* [ÜbersetzerIn]"
    /// - "Sinno, Neige; Meßner, Michaela"
    /// - "Sinno, Neige (VerfasserIn)"
    ///
    /// - parameter defaultRole: the role of persons whose value names none
    static func creators(from value: String, defaultRole: BibliographicRecord.Creator.Role) -> [BibliographicRecord.Creator] {
        // the OPAC separates some persons by a line break only, which the scraper drops
        let separated = value.replacing(pattern: #"(?<=[\]\)])(?=\p{L})"#, with: ";")

        return separated
            .components(separatedBy: ";")
            .compactMap { creator(from: $0, defaultRole: defaultRole) }
    }

    private static func creator(from value: String, defaultRole: BibliographicRecord.Creator.Role) -> BibliographicRecord.Creator? {
        let roles = value.matches(of: #"[\[\(]([^\]\)]*)[\]\)]"#).map { $0.lowercased() }
        let name = value
            // roles, "[VerfasserIn]"
            .replacing(pattern: #"\s*[\[\(][^\]\)]*[\]\)]"#, with: "")
            // life dates, "*1977-*"
            .replacing(pattern: #"\s*\*[^*]*\*"#, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else { return nil }

        let role = roles.lazy.compactMap(role(named:)).first ?? (roles.isEmpty ? defaultRole : .contributor)

        guard let comma = name.firstIndex(of: ",") else {
            return .init(role: role, lastName: name)
        }

        let lastName = name[..<comma].trimmingCharacters(in: .whitespaces)
        let firstName = name[name.index(after: comma)...].trimmingCharacters(in: .whitespaces)

        guard !lastName.isEmpty else {
            return firstName.isEmpty ? nil : .init(role: role, lastName: firstName)
        }

        return .init(role: role, lastName: lastName, firstName: firstName.isEmpty ? nil : firstName)
    }

    /// The role of "[VerfasserIn]", "[Verfasser*in]", "[Herausgeber]", "[Übersetzung]", …
    private static func role(named name: String) -> BibliographicRecord.Creator.Role? {
        if name.hasPrefix("verfasser") || name.hasPrefix("autor") || name.hasPrefix("author") {
            return .author
        } else if name.hasPrefix("herausgeber") || name.hasPrefix("hrsg") || name.hasPrefix("editor") {
            return .editor
        } else if name.hasPrefix("übersetz") || name.hasPrefix("uebersetz") || name.hasPrefix("translat") {
            return .translator
        } else {
            return nil
        }
    }

    /// Place, publisher and year of values like
    /// - "München : dtv, 2024"
    /// - "London ; New York : Verso, 2024"
    /// - "Köln : Böhlau, [2024]"
    /// - "Rheinbreitbach, Deutschland : Ullmann Medien GmbH, 2022?"
    static func publication(from value: String) -> (place: String?, publisher: String?, date: String?) {
        var placeAndPublisher = value
        var date: String?

        // the year follows the last comma
        if let comma = value.range(of: ",", options: .backwards),
           let year = String(value[comma.upperBound...]).matches(of: #"(\d{4})"#).first {
            date = year
            placeAndPublisher = String(value[..<comma.lowerBound])
        } else if let year = value.matches(of: #"(?<!\d)(\d{4})(?!\d)"#).first {
            date = year
            placeAndPublisher = value
                .replacing(pattern: #"[\[\(©\s]*(?<!\d)\d{4}(?!\d)[\]\)\?]*\s*$"#, with: "")
        }

        guard let colon = placeAndPublisher.range(of: " : ") else {
            return (nil, placeAndPublisher.trimmedOrNil, date)
        }

        var place = String(placeAndPublisher[..<colon.lowerBound]).trimmedOrNil
        let publisher = String(placeAndPublisher[colon.upperBound...]).trimmedOrNil

        // "[Erscheinungsort nicht ermittelbar]"
        if let unknownPlace = place?.lowercased(),
           unknownPlace.contains("nicht ermittelbar") || unknownPlace.contains("s.l.") {
            place = nil
        }

        return (place, publisher, date)
    }

    /// The first ISBN of values like
    /// - "9783423284226"
    /// - "978-3-423-28422-6 EUR 24.00 (DE), EUR 24.70 (AT)"
    /// - "978-3-412-52572-9978-3-412-52572-9 digitalWeitere Ausgaben: …"
    /// - "3-219-12027-X"
    static func isbn(in value: String) -> String? {
        let pattern = #"(?<![\d-])(97[89]-\d{1,5}-\d{1,7}-\d{1,6}-\d|97[89]\d{10}|\d{1,5}-\d{1,7}-\d{1,6}-[\dXx]|\d{9}[\dXx])"#

        return value.matches(of: pattern).first { candidate in
            let digits = candidate.filter { $0 != "-" }.count
            return digits == 10 || digits == 13
        }
    }

    /// "Deutsch (Sprache des Originals: Franzoesisch)" → "Deutsch"
    static func language(from value: String) -> String? {
        let language = value.range(of: " (").map { String(value[..<$0.lowerBound]) } ?? value

        return language.trimmedOrNil
    }

    /// The number of pages of values like
    /// - "299 Seiten : Illustrationen"
    /// - "vi, 371 pages"
    /// - "1 Online-Ressource (307 Seiten) : Illustrationen"
    /// - "23 ungezählte Seiten : Illustrationen ; 28 cm"
    static func numberOfPages(in value: String) -> String? {
        value
            .matches(of: #"(\d+)\s*(?:ungezählte\s+|unnumbered\s+)?(?:Seiten|Seite|pages|page|S\.|p\.)"#)
            .first
    }

    /// "Tiere in der Geschichte | Animals in History ; Band 2" → the title and "Band 2"
    static func series(from value: String) -> (title: String?, number: String?) {
        guard let separator = value.range(of: " ; ", options: .backwards) else {
            return (value.trimmedOrNil, nil)
        }

        return (
            String(value[..<separator.lowerBound]).trimmedOrNil,
            String(value[separator.upperBound...]).trimmedOrNil
        )
    }

    /// The keywords of values like
    /// - "Fossil ; Reptilien ; Vor- und Frühgeschichte"
    /// - "*Tiere / Vektor, Epidemiologie / Zoonose*Geschichte der Medizin ; Zoonosen"
    static func tags(from value: String) -> [String] {
        var tags = [String]()

        for part in value.replacingOccurrences(of: " / ", with: ";").components(separatedBy: CharacterSet(charactersIn: ";*")) {
            let tag = part.trimmingCharacters(in: .whitespacesAndNewlines)

            // life dates of persons stand between asterisks as well, "*Foot, Paul *1937-2004* / …"
            let isDate = tag.replacing(pattern: #"[\d\s\.-]"#, with: "").isEmpty

            if !tag.isEmpty, !isDate, !tags.contains(tag) {
                tags.append(tag)
            }
        }

        return tags
    }

    /// "https://doi.org/10.7788/9783412525729" and "DOI: 10.7788/9783412525729" → "10.7788/9783412525729"
    static func doi(from value: String) -> String? {
        value.matches(of: #"(10\.\d{4,9}/\S+)"#).first
    }
}

// MARK: Helpers

private extension String {

    var trimmedOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed.isEmpty ? nil : trimmed
    }

    func replacing(pattern: String, with replacement: String) -> String {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return self }

        return expression.stringByReplacingMatches(
            in: self,
            range: NSRange(startIndex..., in: self),
            withTemplate: replacement
        )
    }

    /// The first capture group of each match of `pattern`
    func matches(of pattern: String) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return [] }

        return expression
            .matches(in: self, range: NSRange(startIndex..., in: self))
            .compactMap { Range($0.range(at: 1), in: self) }
            .map { String(self[$0]) }
    }
}
