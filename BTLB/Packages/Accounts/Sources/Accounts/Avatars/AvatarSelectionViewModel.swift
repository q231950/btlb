//
//  AvatarSelectionViewModel.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 16.02.25.
//

import Foundation

import LibraryUI

class AvatarSelectionViewModel: ObservableObject {
    @Published var currentlySelected: Avatar?
    @Published var selectedTab: String?

    let onAvatarSelection: (String) -> ()
    let onDismiss: () -> ()

    /// The view model to select an avatar from a list of available avatars.
    /// - Parameters:
    ///   - currentlySelected: an optional currently selected avatar
    ///   - avatarSelection: a closure that takes the image name (e.g. "avatar-cat") of an avatar as parameter
    init(currentlySelected: Avatar?, onDismiss: @escaping () -> (), avatarSelection: @escaping (String) -> ()) {
        self.currentlySelected = currentlySelected
        self.selectedTab = currentlySelected?.imageName
        self.onDismiss = onDismiss
        self.onAvatarSelection = avatarSelection
    }

    func isSelected(imageName: String) -> Bool {
        imageName == currentlySelected?.imageName
    }

    func dismiss() {
        onDismiss()
    }

    func saveAndDismiss() {
        if let selectedTab {
            onAvatarSelection(selectedTab)
        }
    }
}
