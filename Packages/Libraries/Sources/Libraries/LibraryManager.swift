import Foundation
import CoreData
import Foundation
import os.log

import LibraryCore
import Persistence

private enum Constants {
    static let settingsSearchLibrary = "search_Library"
    static let versionKey = "version"
    static let defaultSearchLibraryIdentifier = "HAMBURGPUBLIC"
    static let librariesKey = "Libraries"
    static let baseUrlKey = "base_url"
    static let catalogUrlKey = "catalog_url"
    static let libraryIdentifierKey = "identifier"
    static let librarySubtitleKey = "subtitle"
    static let libraryNameKey = "name"
    static let defaultLibraryIdentifier = "HAMBURGPUBLIC"
    /// Libraries that have been merged into another library, by their former identifier
    static let mergedLibraryIdentifiers = [
        // StabiKat searched the catalog of the Staatsbibliothek, which BERLIN searches now
        "STABIKAT": "BERLIN"
    ]
}

public final class LibraryManager: LibraryProvider {
    private let persistentContainer: PersistentContainer
    private let userDefaults: UserDefaults
    var amountOfLibrariesToProcess: UInt = 0

    public var legacySearchLibrary: NSManagedObjectID? {
        return searchLibrary
    }

    public var searchLibrary: NSManagedObjectID? {
        let libraryIdentifier = userDefaults.string(forKey: Constants.settingsSearchLibrary)
        ?? Constants.defaultSearchLibraryIdentifier

        if userDefaults.string(forKey: Constants.settingsSearchLibrary) == nil {
            userDefaults.set(libraryIdentifier, forKey: Constants.settingsSearchLibrary)
        }

        return library(forIdentifier: libraryIdentifier,
                       in: persistentContainer.newBackgroundContext())
    }

    public var defaultLibrary: NSManagedObjectID? {
        library(forIdentifier: Constants.defaultLibraryIdentifier,
                in: persistentContainer.viewContext)
    }

    public init(persistentContainer: PersistentContainer, userDefaults: UserDefaults = .standard) {
        self.persistentContainer = persistentContainer
        self.userDefaults = userDefaults
    }
    
    public func library(forIdentifier identifier: String, in context: NSManagedObjectContext?) -> NSManagedObjectID? {
        guard let context = context else { return nil }
        
        var resultID: NSManagedObjectID?
        context.performAndWait {
            let fetchRequest: NSFetchRequest<Persistence.Library> = Persistence.Library.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
            
            if let library = try? context.fetch(fetchRequest).first {
                resultID = library.objectID
            }
        }
        return resultID
    }

    public func loadOrUpdateLibraries(
        in context: NSManagedObjectContext?,
        libraryProvider: LibraryModelProvider
    ) {
        let libraries = libraryProvider.libraries()

        // without any provided libraries there is nothing to tell removed libraries apart by
        guard !libraries.isEmpty else { return }

        if let context {
            libraries.forEach { library in
                insertOrUpdateLibrary(with: library, context: context)
            }

            removeLibraries(notIn: libraries, in: context)
        }

        replaceSearchLibraryIfRemoved(providedIdentifiers: Set(libraries.compactMap(\.identifier)))
    }

    /// Removes the stored libraries that are no longer provided, e.g. because they have been merged into another library.
    /// Libraries that accounts or loans still belong to are kept, but can no longer be selected.
    func removeLibraries(notIn libraries: [any LibraryCore.Library], in context: NSManagedObjectContext) {
        let providedIdentifiers = libraries.compactMap(\.identifier)

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Persistence.Library> = Persistence.Library.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "NOT (identifier IN %@)", argumentArray: [providedIdentifiers])

            guard let removedLibraries = try? context.fetch(fetchRequest) else { return }

            for library in removedLibraries {
                let isInUse = (library.libraryAccounts?.count ?? 0) > 0 || (library.libraryLoans?.count ?? 0) > 0

                if isInUse {
                    library.enabledForSearch = false
                    library.enabledForLogin = false
                } else {
                    context.delete(library)
                }
            }

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    Logger.libraries.error("Error removing libraries that are no longer provided\n\(error.localizedDescription)")
                }
            }
        }
    }

    /// Searches the library a removed search library has been merged into, or the default library
    func replaceSearchLibraryIfRemoved(providedIdentifiers: Set<String>) {
        guard let identifier = userDefaults.string(forKey: Constants.settingsSearchLibrary),
              !providedIdentifiers.contains(identifier) else { return }

        if let mergedIdentifier = Constants.mergedLibraryIdentifiers[identifier],
           providedIdentifiers.contains(mergedIdentifier) {
            userDefaults.set(mergedIdentifier, forKey: Constants.settingsSearchLibrary)
        } else {
            userDefaults.removeObject(forKey: Constants.settingsSearchLibrary)
        }
    }

    func libraries(in context: NSManagedObjectContext, completion: @escaping ([Persistence.Library]) -> Void) {
        Task {
            do {
                completion(try await persistentContainer.libraries(in: context))
            } catch let error {
                Logger.libraries.error("Error loading libraries from persistent container\n\(error.localizedDescription)")
                completion([])
            }
        }
    }

    private var currentLibrariesVersion: NSNumber {
        get {
            NSNumber(value: UserDefaults.standard.integer(forKey: Constants.versionKey))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.versionKey)
        }
    }
    
    private func insertOrUpdateLibrary(with libraryModel: any LibraryCore.Library, context: NSManagedObjectContext) {
        guard let identifier = libraryModel.identifier else { return }

        let libraryManagedObject: Persistence.Library
        if let existingLibraryID = library(forIdentifier: identifier, in: context),
           let existing = try? context.existingObject(with: existingLibraryID) as? Persistence.Library {
            libraryManagedObject = existing
        } else {
            libraryManagedObject = Library(context: context)
        }
        
        libraryManagedObject.identifier = identifier
        libraryManagedObject.subtitle = libraryModel.subtitle
        libraryManagedObject.name = libraryModel.name
        libraryManagedObject.enabledForLogin = libraryModel.enabledForLogin
        libraryManagedObject.enabledForSearch = libraryModel.enabledForSearch

        try? context.save()
    }
}
