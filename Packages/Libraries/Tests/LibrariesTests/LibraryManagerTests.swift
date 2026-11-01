import CoreData
import XCTest

import LibraryCore
@testable import Libraries
import Persistence

final class LibraryManagerTests: XCTestCase {

    /// A single in-memory store for all tests, loading the managed object model more than once
    /// leaves Core Data unable to tell which entity a managed object subclass belongs to
    private static let dataStackProvider: DataStackProvider = {
        let dataStackProvider = DataStackProvider()
        dataStackProvider.loadInMemory()
        return dataStackProvider
    }()

    private let searchLibraryKey = "search_Library"
    private let userDefaultsSuiteName = "LibraryManagerTests"

    private var container: PersistentContainer!
    private var context: NSManagedObjectContext!
    private var userDefaults: UserDefaults!
    private var sut: LibraryManager!

    override func setUpWithError() throws {
        container = try XCTUnwrap(Self.dataStackProvider.persistentContainer)
        context = container.viewContext
        deleteAll(entityName: "Account")
        deleteAll(entityName: "Library")

        userDefaults = try XCTUnwrap(UserDefaults(suiteName: userDefaultsSuiteName))
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)

        sut = LibraryManager(persistentContainer: container, userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
        super.tearDown()
    }

    // MARK: Libraries

    func test_onlyBerlinIsLeftOfTheStaatsbibliothek_afterStabiKatWasMergedIntoIt() {
        // the libraries of a build that still provided StabiKat
        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin, .stabikat, .hamburg]))
        XCTAssertEqual(storedLibraryIdentifiers(), ["BERLIN", "HAMBURG", "STABIKAT"])

        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin, .hamburg]))

        XCTAssertEqual(storedLibraryIdentifiers(), ["BERLIN", "HAMBURG"])
    }

    func test_keepsRemovedLibraries_thatAccountsBelongTo_butDisablesThem() throws {
        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin, .stabikat]))
        let stabikat = try XCTUnwrap(storedLibrary(identifier: "STABIKAT"))
        let account = EDAccount(context: context)
        account.accountLibrary = stabikat
        try context.save()

        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin]))

        let removedLibrary = try XCTUnwrap(storedLibrary(identifier: "STABIKAT"))
        XCTAssertFalse(removedLibrary.enabledForSearch)
        XCTAssertFalse(removedLibrary.enabledForLogin)
        XCTAssertEqual(account.accountLibrary, removedLibrary)
    }

    func test_keepsStoredLibraries_whenNoLibrariesAreProvided() {
        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin]))

        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: []))

        XCTAssertEqual(storedLibraryIdentifiers(), ["BERLIN"])
    }

    // MARK: Search Library

    func test_searchesBerlin_whenStabiKatWasTheSearchLibrary() throws {
        userDefaults.set("STABIKAT", forKey: searchLibraryKey)

        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin, .hamburg]))

        XCTAssertEqual(userDefaults.string(forKey: searchLibraryKey), "BERLIN")
        let berlin = try XCTUnwrap(storedLibrary(identifier: "BERLIN"))
        XCTAssertEqual(sut.searchLibrary, berlin.objectID)
    }

    func test_searchesTheDefaultLibrary_whenTheSearchLibraryWasRemoved() {
        userDefaults.set("REMOVED", forKey: searchLibraryKey)

        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin, .hamburg]))

        XCTAssertNil(userDefaults.string(forKey: searchLibraryKey))
    }

    func test_keepsTheSearchLibrary_whenItIsStillProvided() {
        userDefaults.set("HAMBURG", forKey: searchLibraryKey)

        sut.loadOrUpdateLibraries(in: context, libraryProvider: LibraryModelProviderStub(libraries: [.berlin, .hamburg]))

        XCTAssertEqual(userDefaults.string(forKey: searchLibraryKey), "HAMBURG")
    }

    // MARK: Helpers

    private func storedLibrary(identifier: String) -> Persistence.Library? {
        let fetchRequest: NSFetchRequest<Persistence.Library> = Persistence.Library.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)

        return try? context.fetch(fetchRequest).first
    }

    private func storedLibraryIdentifiers() -> [String] {
        let fetchRequest: NSFetchRequest<Persistence.Library> = Persistence.Library.fetchRequest()

        return ((try? context.fetch(fetchRequest)) ?? [])
            .compactMap(\.identifier)
            .sorted()
    }

    /// Batch deletes are not supported by in-memory stores
    private func deleteAll(entityName: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)

        ((try? context.fetch(fetchRequest)) ?? []).forEach(context.delete)
        try? context.save()
    }
}

private struct LibraryModelProviderStub: LibraryModelProvider {
    let providedLibraries: [LibraryModel]

    init(libraries: [LibraryModel]) {
        self.providedLibraries = libraries
    }

    func libraries() -> [any LibraryCore.Library] {
        providedLibraries
    }

    func library(for identifier: String) -> (any LibraryCore.Library)? {
        providedLibraries.first { $0.identifier == identifier }
    }
}

private extension LibraryModel {
    static let berlin = LibraryModel(name: "Berlin", subtitle: "Staatsbibliothek Preußischer Kulturbesitz", identifier: "BERLIN")
    static let stabikat = LibraryModel(name: "Berlin", subtitle: "StabiKat – Staatsbibliothek zu Berlin", identifier: "STABIKAT", enabledForLogin: false)
    static let hamburg = LibraryModel(name: "Hamburg", subtitle: "Staats und Universitätsbibliothek Hamburg", identifier: "HAMBURG")
}
