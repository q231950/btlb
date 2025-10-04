//
//  DataModelStack.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 31.12.18.
//  Copyright © 2018 neoneon. All rights reserved.
//

import CoreData
import Foundation

class DataModelStack {

    private let DataModelStackVersionKey = "DataModelStackVersion"
    private let CurrentDataModelStackVersion = 1

    public var persistentContainer: PersistentContainer?

    public func configureDefaultPersistentContainer() {
        guard let mom = NSManagedObjectModel.mergedModel(from: [.main, .module]) else {
            fatalError("Failed to create merged model from bundle: \(Bundle.main)")
        }


        // https://useyourloaf.com/blog/sharing-data-with-a-widget/

        persistentContainer = PersistentContainer(name: "EDsyncSquared", managedObjectModel: mom)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didSaveNotification(notification:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    public func configurePersistentContainer(inMemory: Bool = false) {
        guard let mom = NSManagedObjectModel.mergedModel(from: [.main, .module]) else {
            fatalError("Failed to create merged model from bundle: \(Bundle.main)")
        }

        let storeDescription = NSPersistentStoreDescription()

        if inMemory {
            storeDescription.type = NSInMemoryStoreType
        }

        persistentContainer = PersistentContainer(name: "EDsyncSquared", managedObjectModel: mom)
        persistentContainer?.persistentStoreDescriptions = [storeDescription]

        persistentContainer?.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        })

        NotificationCenter.default.addObserver(self, selector: #selector(self.didSaveNotification(notification:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    @objc func didSaveNotification(notification: Notification) {
        persistentContainer?.viewContext.perform {
            self.persistentContainer?.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }

    func loadStore(completion: @escaping (() -> Void)) {
        if needsSQLiteMigration() {
            migrateLegacySQLite()
        }

        persistentContainer?.loadPersistentStores { (storeDescription, error) in
            completion()
        }
    }

    func resetStore() {
        guard let mom = NSManagedObjectModel.mergedModel(from: [.main, .module]) else {
            fatalError("Failed to create merged model from bundle: \(Bundle.main)")
        }


        // https://useyourloaf.com/blog/sharing-data-with-a-widget/

        persistentContainer = PersistentContainer(name: "EDsyncSquared", managedObjectModel: mom)
    }
}

/// Migration
extension DataModelStack {

    /**
     This method checks whether or not there is a legacy store that needs to be migrated

     - Returns: true when a migration is needed
     */
    private func needsSQLiteMigration() -> Bool {
        UserDefaults.standard.integer(forKey: DataModelStackVersionKey) < CurrentDataModelStackVersion
    }

    private func finishSQLiteMigration(to version: Int) {
        UserDefaults.standard.set(version, forKey: DataModelStackVersionKey)
    }

    private func migrateLegacySQLite() {
        let sourceDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let targetDirectoryURL = NSPersistentContainer.defaultDirectoryURL()

        guard let sourceSqliteURL = URL(string: "EDsyncSquared.sqlite", relativeTo: sourceDirectoryURL),
            let sourceShmURL = URL(string: "EDsyncSquared.sqlite-shm", relativeTo: sourceDirectoryURL),
            let sourceWalURL = URL(string: "EDsyncSquared.sqlite-wal", relativeTo: sourceDirectoryURL),
            let targetSqliteURL = URL(string: "EDsyncSquared.sqlite", relativeTo: targetDirectoryURL),
            let targetShmURL = URL(string: "EDsyncSquared.sqlite-shm", relativeTo: targetDirectoryURL),
            let targetWalURL = URL(string: "EDsyncSquared.sqlite-wal", relativeTo: targetDirectoryURL) else {
                return
        }

        let fm = FileManager.default
        do {
            let d = try Data(contentsOf: sourceSqliteURL)
            if d.endIndex != d.startIndex {

                if !fm.fileExists(atPath: targetSqliteURL.absoluteString) {
                    do {
                        try fm.moveItem(at: sourceSqliteURL, to: targetSqliteURL)
                        try fm.moveItem(at: sourceShmURL, to: targetShmURL)
                        try fm.moveItem(at: sourceWalURL, to: targetWalURL)

                    } catch {
                        print("CoreData stack alrady setup.")
                    }
                }
            }

            finishSQLiteMigration(to: CurrentDataModelStackVersion)
        } catch {
        }
    }
}
