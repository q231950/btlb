//
//  Logger+tests.swift
//  BTLBUITests
//
//  Created by Martin Kim Dung-Pham on 09.01.24.
//  Copyright © 2024 neoneon. All rights reserved.
//

import Foundation
import os

private let subsystem = "com.elbedev.sync"

public extension Logger {
    static let tests = Logger(subsystem: subsystem, category: "tests")
}
