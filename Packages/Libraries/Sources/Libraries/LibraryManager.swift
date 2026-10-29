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
}

public final class LibraryManager: LibraryProvider {
    private let persistentContainer: PersistentContainer
    var amountOfLibrariesToProcess: UInt = 0

    public var legacySearchLibrary: NSManagedObjectID? {
        return searchLibrary
    }

    public var searchLibrary: NSManagedObjectID? {
        let libraryIdentifier = UserDefaults.standard.string(forKey: Constants.settingsSearchLibrary)
        ?? Constants.defaultSearchLibraryIdentifier

        if UserDefaults.standard.string(forKey: Constants.settingsSearchLibrary) == nil {
            UserDefaults.standard.set(libraryIdentifier, forKey: Constants.settingsSearchLibrary)
        }

        return library(forIdentifier: libraryIdentifier,
                       in: persistentContainer.newBackgroundContext())
    }

    public var defaultLibrary: NSManagedObjectID? {
        library(forIdentifier: Constants.defaultLibraryIdentifier,
                in: persistentContainer.viewContext)
    }

    public init(persistentContainer: PersistentContainer) {
        self.persistentContainer = persistentContainer
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

        if let context {
            libraries.forEach { library in
                insertOrUpdateLibrary(with: library, context: context)
            }
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
