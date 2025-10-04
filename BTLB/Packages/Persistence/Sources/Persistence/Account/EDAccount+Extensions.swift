//
//  EDAccount+Extensions.swift
//  
//
//  Created by Martin Kim Dung-Pham on 25.11.22.
//

import Foundation
import struct LibraryCore.RenewableItem

@objc public extension EDAccount {

    @objc var accountIdentifier: String {
        "\(accountName ?? "") " + "\(accountUserID ?? UUID().uuidString) "
    }
}

public extension EDAccount {

    enum SectionTitleStyle {
        case loans
        case charges
    }

    func sectionTitle(_ style: SectionTitleStyle) -> String {
        "\(accountName ?? "") • \(accountUserID ?? "") "
    }
}

public extension EDAccount {

    var renewableItems: [RenewableItem] {
        get async {
            var renewableItems = [RenewableItem]()

            let moc = managedObjectContext
            await moc?.perform {
                self.allLoans.forEach({ loanManagedObject in
                    if let loan = loanManagedObject as? Loan {
                        renewableItems.append(RenewableItem(now: .now,
                                                            title: loan.title,
                                                            barcode: loan.barcode,
                                                            canRenew: loan.canRenew,
                                                            expirationDate: loan.loanExpiryDate ?? Date(),
                                                            expirationNotificationDate: loan.notificationScheduledDate) { notificationTriggerDate in

                            await moc?.perform {
                                if let loan = moc?.object(with: loan.objectID) as? Loan {
                                    loan.notificationScheduledDate = notificationTriggerDate
                                    do {
                                        try moc?.save()
                                    } catch {

                                    }
                                }
                            }
                        })
                    }
                })
            }

            return renewableItems
        }
    }
}
