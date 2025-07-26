//
//  CoordinatorProviding.swift
//  Utilities
//
//  Created by Martin Kim Dung-Pham on 03.07.25.
//

import ArchitectureX

import SwiftUI

public protocol CoordinatorProviding {
    func coordinator(for: Route) -> any Coordinator
}

public extension EnvironmentValues {
    var coordinatorProvider: any CoordinatorProviding {
        get { self[CoordinatorProviderKey.self] }
        set { self[CoordinatorProviderKey.self] = newValue }
    }
}

public struct CoordinatorProviderKey: EnvironmentKey {
    public static let defaultValue: any CoordinatorProviding = NoOpCoordinatorProvider()
}

public final class EmptyCoordinator: Coordinator {
    public var router: ArchitectureX.Router?

    public init(router: ArchitectureX.Router? = nil) {
        self.router = router
    }

    public var contentView: some View {
        EmptyView()
    }
}

struct NoOpCoordinatorProvider: CoordinatorProviding {
    var searchCoordinator: any Coordinator {
        EmptyCoordinator()
    }

    func coordinator(for route: Route) -> any Coordinator {
        EmptyCoordinator()
    }
}
