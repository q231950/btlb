//
//  LibrarySelectionCoordinator.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 16.02.22.
//  Copyright © 2022 neoneon. All rights reserved.
//

import Foundation
import SwiftUI

import LibraryCore
import Persistence

public class LibrarySelectionCoordinator<L: LibraryCore.Library> {
    let currentlySelectedIdentifier: String?
    let librarySelectionType: LibrarySelectionType
    let librarySelection: @MainActor (_ selectedLibrary: L) -> ()

    public init(for librarySelectionType: LibrarySelectionType, currentlySelected identifier: String? = nil, librarySelection: @escaping @MainActor (_ selectedLibrary: L) -> ()) {
        self.currentlySelectedIdentifier = identifier
        self.librarySelectionType = librarySelectionType
        self.librarySelection = librarySelection
    }

    @MainActor public var contentView: some View {
        let viewModel = LibrarySelectionViewModel(for: librarySelectionType, currentlySelected: currentlySelectedIdentifier, librarySelection: librarySelection)

        return LibrarySelectionView<L>(viewModel: viewModel)

    }
}
