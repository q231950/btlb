//
//  Logger.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 12.01.19.
//  Copyright © 2019 neoneon. All rights reserved.
//

import Foundation
import os.log
import os.signpost

private let subsystem = "com.elbedev.sync"

public extension OSLog {
    /**
     * Example usage:
     * ```swift
     * let signpostID = OSSignpostID(log: .searchCell)
     * os_signpost(.event, log: .searchCell, name: "load image", signpostID: signpostID)
     *
     * print("[image bug] load")
     * os_log("loadImage start", log: OSLog.searchCell, type: .debug)
     *
     * os_signpost(.event, log: .searchCell, name: "load image", signpostID: signpostID)
     * os_signpost(.begin, log: .searchCell, name: "")
     * ```
     */
    static let searchCell = OSLog(subsystem: subsystem, category: "SearchResultCollectionViewCell")
}

public extension Logger {
    static let about = Logger(subsystem: subsystem, category: "about")
    static let account = Logger(subsystem: subsystem, category: "account")
    static let accountActivation = Logger(subsystem: subsystem, category: "account activation")
    static let accountUpdating = Logger(subsystem: subsystem, category: "account updating")
    static let accountRepository = Logger(subsystem: subsystem, category: "account repository")
    static let app = Logger(subsystem: subsystem, category: "app")
    static let editAccount = Logger(subsystem: subsystem, category: "edit account")
    static let libraries = Logger(subsystem: subsystem, category: "libraries")
    static let loans = Logger(subsystem: subsystem, category: "loans")
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
    static let search = Logger(subsystem: subsystem, category: "search")
    static let utilities = Logger(subsystem: subsystem, category: "utilities")
}

