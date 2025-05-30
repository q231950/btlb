//
//  AvatarSelectionView.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 16.02.25.
//

import Foundation
import SwiftUI

import LibraryUI

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: AvatarSelectionViewModel

    private let availableAvatars: [String] = AccountTemplate.allCases.map(\.self.avatar.imageName)

    var body: some View {
        VStack {
            Text("Choose your avatar", bundle: .module)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing])

            avatarTabs

            Spacer()
        }
    }

    private var avatarTabs: some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView(selection: $viewModel.selectedTab) {
                    ForEach(availableAvatars, id: \.self) { name in
                        Tab(value: name) {
                            tabContent(avatarImageName: name)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            } else {
                VStack {
                    TabView(selection: $viewModel.selectedTab) {
                        ForEach(availableAvatars, id: \.self) { name in
                            tabContent(avatarImageName: name)
                                .tag(name)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
        }
    }

    private func tabContent(avatarImageName: String) -> some View {
        VStack {
            Button(action: {
                self.viewModel.onAvatarSelection(avatarImageName)
            }) {
                HStack {
                    AvatarView(avatarImageName, size: .large, selected: viewModel.isSelected(imageName: avatarImageName))
                }
            }
            .padding(.top, 80)

            Spacer()
        }
    }
}

#Preview {
    let viewModel = AvatarSelectionViewModel(currentlySelected: .cat, onDismiss: {}) { avatar in }

    NavigationView {
        AvatarSelectionView(viewModel: viewModel)
            .navigationTitle("Avatars")
    }
}
