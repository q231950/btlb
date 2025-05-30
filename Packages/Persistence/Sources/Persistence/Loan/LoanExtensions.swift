//
//  Loan.swift
//  
//
//  Created by Martin Kim Dung-Pham on 09.09.22.
//

import Foundation
import CoreData
import LibraryCore

extension Loan: LibraryCore.Loan {

    public var libraryIdentifier: String {
        loanLibrary?.identifier ?? "unknown"
    }

    public var title: String {
        loanTitle ?? ""
    }

    public var subtitle: String {
        author ?? ""
    }

    public var dueDate: Date {
        loanExpiryDate ?? .now
    }

    public var shelfmark: String {
        loanSignature ?? ""
    }

    public var iconUrl: String? {
        loanIconUrl
    }

    public var renewalCount: Int {
        loanTimesProlonged?.intValue ?? 0
    }

    public var canRenew: Bool {
        loanCanRenew
    }

    public var renewalToken: String? {
        loanRenewalToken
    }

    public var lockedByPreorder: Bool {
        loanLockedByPreorder
    }

    public var volume: String? {
        loanVolume
    }

    public var barcode: String {
        loanBarcode ?? ""
    }

    public var bookmarked: Bool {
        get {
            loanIsFavourite?.boolValue ?? false
        }
        set {
            loanIsFavourite = NSNumber(value: newValue)
        }
    }

    public var infos: [LibraryCore.Info] {
        guard let items = infoPair?.allObjects as? [InfoPair] else { return [] }

        return items.map {
            LibraryCore.Info(title: $0.title ?? "", value: $0.value ?? "")
        }
    }

    public var notificationScheduledDate: Date? {
        get {
            loanNotificationScheduledDate
        }
        set {
            loanNotificationScheduledDate = newValue
        }

    }
}

public extension Loan {

    func createOrUpdateInfoPair(title: String, value: String) {
        if let pair = storedInfoPair(title: title) {
            pair.value = value
        } else {
            storeInfoPair(title: title, value: value)
        }
    }

    private func storedInfoPair(title: String) -> InfoPair? {
        guard let pairs = infoPair?.allObjects as? [InfoPair] else {
            return nil
        }

        return pairs.first (where: { $0.title == title })
    }

    private func storeInfoPair(title: String, value: String) {
        let pair = InfoPair.init(entity: InfoPair.entity(), insertInto: managedObjectContext)
        pair.title = title
        pair.value = value
        pair.loan = self
        addToInfoPair(pair)
    }

}
