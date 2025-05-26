//
//  Loan+Serialization.swift
//  
//
//  Created by Martin Kim Dung-Pham on 19.11.22.
//

import Foundation
import CoreData
import CryptoKit
import LibraryCore

public struct LoanSerializer {

    public init() {}

    // TODO: add tests
    public func loansHash(for accountId: NSManagedObjectID) async throws -> String {

        var account: EDAccount?
        let moc = DataStackProvider.shared.backgroundManagedObjectContext

        await moc.perform {
            account =  moc.object(with: accountId) as? EDAccount
        }

        guard let account else {
            throw PaperErrorInternal.loanSerializerError(.accountDoesNotExist)
        }

        return await account.managedObjectContext?.perform {
            var serialized = account.accountName ?? "\(String(describing: account.accountCreationDate))"
            if let loans = account.loans {
                let sortedLoans = loans.sortedArray(using: [NSSortDescriptor(key: "loanTitle", ascending: true)])
                serialized += sortedLoans.map(loanHashMap).joined()
            }

            let digest = SHA256.hash(data: serialized.data(using: .utf8) ?? Data())

            return "\(digest)"
        } ?? ""
    }

    // TODO: add tests
    public func loansBarcodes(for accountId: NSManagedObjectID) async throws -> [String] {
        var account: EDAccount?
        let moc = DataStackProvider.shared.backgroundManagedObjectContext

        await moc.perform {
            account =  moc.object(with: accountId) as? EDAccount
        }

        guard let account else {
            throw PaperErrorInternal.loanSerializerError(.accountDoesNotExist)
        }

        return await moc.perform {
            if let loans = account.loans {
                return loans.compactMap { anyLoan in
                    if let loan = anyLoan as? Loan {
                        return loan.barcode
                    } else {
                        return nil
                    }
                }
            } else {
                return []
            }
        } ?? []
    }

    func loanHashMap(anyLoan: Any) -> (String) {
        if let loan = anyLoan as? Loan {
            return loan.sha256
        } else {
            return ""
        }
    }
}

public extension Loan {

    static let entityName = "Loan"

    internal var sha256: String {
        let title = loanTitle ?? ""
        let signature = loanSignature ?? ""
        return "\(title)-\(signature)-\(String(describing: loanExpiryDate))"
    }
}
