//
//  AvatarSelectionCoordinator.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 14.02.25.
//

import Foundation
import SwiftUI

import LibraryUI

public class AvatarSelectionCoordinator {
    private let avatarSelection: @MainActor (_ selectedAvatar: String) -> ()
    private let onCancel: () -> ()
    let currentlySelectedAvatar: Avatar?

    public init(currentlySelected name: String?, onCancel: @escaping () -> (), avatarSelection: @escaping @MainActor (_ selectedAvatar: String) -> ()) {
        self.currentlySelectedAvatar = Avatar(imageName: name)
        self.onCancel = onCancel
        self.avatarSelection = avatarSelection
    }

    @MainActor public var contentView: some View {
        let viewModel = AvatarSelectionViewModel(currentlySelected: currentlySelectedAvatar, onDismiss: onCancel, avatarSelection: avatarSelection)

        return AvatarSelectionContainerView(viewModel: viewModel)

    }
}
