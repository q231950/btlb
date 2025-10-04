//
//  Logger+AppIntents.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 13.02.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import OSLog

extension Logger {
    static let intentLogging = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "App Intent")
}
