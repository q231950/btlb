//
//  AvatarSelectionContainerView.swift
//  Accounts
//
//  Created on 25.05.25.
//

import SwiftUI
import LibraryUI

struct AvatarSelectionContainerView: View {
    @ObservedObject var viewModel: AvatarSelectionViewModel
    @AppStorage("avatarSelectionViewType") private var showGridView = true
    
    init(viewModel: AvatarSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if showGridView {
                AvatarSelectionGridView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button {
                                showGridView.toggle()
                            } label: {
                                Image(systemName: "squares.below.rectangle")
                            }
                            .accessibilityLabel("Switch to list view")
                        }
                    }
            } else {
                AvatarSelectionView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button {
                                showGridView.toggle()
                            } label: {
                                Image(systemName: "rectangle.grid.2x2")
                            }
                            .accessibilityLabel("Switch to grid view")
                        }
                    }
            }
        }
        .navigationTitle(Text("Avatars", bundle: .module))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    viewModel.dismiss()
                }) {
                    Text("Cancel", bundle: .localization)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.saveAndDismiss()
                }) {
                    Text("Done", bundle: .localization)
                        .bold()
                }
                .disabled(viewModel.selectedTab == nil)
            }
        }
    }
}

#Preview {
    let viewModel = AvatarSelectionViewModel(
        currentlySelected: Avatar(imageName: "avatar-tiger"),
        onDismiss: {},
        avatarSelection: { _ in }
    )
    
    return NavigationStack {
        AvatarSelectionContainerView(viewModel: viewModel)
            .navigationTitle("Choose Avatar")
    }
}
