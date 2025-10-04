//
//  UpdateResult.swift
//  
//
//  Created by Martin Kim Dung-Pham on 29.12.22.
//

import Foundation

public enum UpdateResult: Equatable {
    case finished(hasChanges: Bool, renewableItems: [RenewableItem], returnedItems: [String], errors: [PaperErrorInternal])
    case error(PaperErrorInternal)

    public var hasChanges: Bool {
        switch self {
        case .finished(let hasChanges, _, _, _):
            return hasChanges
        case .error:
            return false
        }
    }

    public var isError: Bool {
        if case .error = self {
            return true
        } else {
            return false
        }
    }

    public var renewableItems: [RenewableItem] {
        switch self {
        case .finished(_, let renewableItems, _, _):
            return renewableItems
        case .error:
            return []
        }
    }

    public var returnedItems: [String] {
        switch self {
        case .finished(_, _, let returnedItems, _):
            return returnedItems
        case .error:
            return []
        }
    }

    public var errors: [PaperErrorInternal] {
        switch self {
        case .finished(hasChanges: _, renewableItems: _, returnedItems: _, errors: let errors):
            return errors
        case .error(let error):
            return [error]
        }
    }
}
