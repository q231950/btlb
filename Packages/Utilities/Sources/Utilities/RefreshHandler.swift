//
//  RefreshHandler.swift
//  
//
//  Created by Martin Kim Dung-Pham on 23.02.23.
//

import Foundation

public protocol Refreshable {
    func refresh() async throws
}

public final class RefreshHandler: Refreshable {

    var operation: () async throws -> Void

    public init(operation: @escaping () async throws -> Void) {
        self.operation = operation
    }

    public func refresh() async throws {
        try await operation()
    }
}
