//
//  AppGroup.swift
//  
//
//  Created by Martin Kim Dung-Pham on 30.11.22.
//

import Foundation

public enum AppGroup: String {
    case btlb = "group.com.elbedev.sync"

    public var containerURL: URL {
        switch self {
        case .btlb:
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
}
