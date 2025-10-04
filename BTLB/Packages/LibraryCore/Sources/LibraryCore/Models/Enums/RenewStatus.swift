//
//  RenewStatus.swift
//  
//
//  Created by Martin Kim Dung-Pham on 22.11.22.
//

import Foundation

public enum RenewStatus: Equatable {
    case success(dueDate: String, renewalsCount:Int, canRenew:Bool)
    case failure
    case error(Error)

    public static func == (lhs: RenewStatus, rhs: RenewStatus) -> Bool {
        switch (lhs, rhs) {
        case let (.success(aDueDate, aRenewalsCount, aCanRenew), .success(bDueDate, bRenewalsCount, bCanRenew)): aDueDate == bDueDate && aRenewalsCount == bRenewalsCount && aCanRenew == bCanRenew
        case (.failure, .failure): true
        case let (.error(e1), .error(e2)): e1.localizedDescription == e2.localizedDescription
        default: false
        }
    }
}

