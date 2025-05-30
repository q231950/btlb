//
//  ContentPublisher.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.08.22.
//

import Foundation
import Combine
import os.log
import CoreData

extension NSNotification.Name {
    static let accountUpdate = NSNotification.Name("DID_PERFORM_ACCOUNTS_UPDATE")
}

public protocol AppEventObserver {
    func handle(_ change: AppEventPublisher.AppEvent) async throws
    var id: UUID { get }
}

/// Publishes Events about changes in content
public class AppEventPublisher {

    public static let shared = AppEventPublisher()

    /// Events that can happen in the app.
    public enum AppEvent {

        case accountActivation(count: Int, activated: Int, context: NSManagedObjectContext)
        case accountsRefreshed(result: UpdateResult, context: NSManagedObjectContext)

        /// notification settings (e.g. _expiration reminder threshold in days_) have changed.
        case settingChange(renewableItems: [RenewableItem])

        // The item has successfully been renewed
        case renewalSuccess(RenewableItem, context: NSManagedObjectContext)
        // The item could not be renewed
        case renewalFailure(title: String, barcode: String) // The item could not be renewed
    }

    private var observers = [AppEventObserver]()

    public func addObserver(_ observer: AppEventObserver) {
        if !observers.contains(where: { $0.id == observer.id }) {
            observers.append(observer)
        }
    }

    public func sendUpdate(_ change: AppEvent) async throws {
        Logger.account.info("sendUpdate \(change)")
        Logger.account.info("Observers: \(self.observers) change: \(change)")
        await withThrowingTaskGroup(of: Void.self) { group in
            observers.forEach { observer in
                group.addTask {
                    try await observer.handle(change)
                }
            }
        }
    }
}

extension AppEventPublisher.AppEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .accountActivation(let count, let activated, _): return "accounts count: \(count) activated: \(activated)"
        case .accountsRefreshed: return "accountsRefreshed"
        case .settingChange(let renewableItems): return "scheduleNotifications: \(renewableItems.map { $0.title })"
        case .renewalSuccess(let item, _): return "renewal success: \(item.title)"
        case .renewalFailure(let title, _): return "renewal failure: \(title)"
        }
    }
}
