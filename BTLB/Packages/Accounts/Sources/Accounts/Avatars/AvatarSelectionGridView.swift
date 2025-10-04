//
//  AvatarSelectionGridView.swift
//  Accounts
//
//  Created by Martin Kim Dung-Pham on 25.05.25.
//

import SwiftUI
import LibraryUI

struct AvatarSelectionGridView: View {
    @ObservedObject var viewModel: AvatarSelectionViewModel
    @Namespace private var avatarNamespace
    
    // Grid configuration
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    private let availableAvatars: [String] = AccountTemplate.allCases.map(\.self.avatar.imageName)
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(availableAvatars, id: \.self) { avatar in
                        AvatarGridItem(
                            avatar: avatar,
                            isSelected: viewModel.isSelected(imageName: avatar)
                        )
                        .id(avatar)
                        .onTapGesture {
                            viewModel.onAvatarSelection(avatar)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                if let selectedAvatar = viewModel.currentlySelected?.imageName {
                    scrollProxy.scrollTo(selectedAvatar, anchor: .center)
                }
            }
            .onChange(of: viewModel.selectedTab) { newValue in
                if let selectedAvatar = newValue {
                    withAnimation {
                        scrollProxy.scrollTo(selectedAvatar, anchor: .center)
                    }
                }
            }
        }
    }
}

// Grid item component for displaying an individual avatar
struct AvatarGridItem: View {

    let avatar: String
    let isSelected: Bool


    var body: some View {

        VStack {

            AvatarView(avatar, size: .standard)

                .overlay(

                    Circle()

                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)

                )

                .padding(4)



            if isSelected {

                Image(systemName: "checkmark.circle.fill")

                    .foregroundColor(.accentColor)

            }

        }

        .padding(12)

        .background(

            RoundedRectangle(cornerRadius: 12)

                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)

        )

    }

}

// Preview for the grid view
#Preview {

    let viewModel = AvatarSelectionViewModel(

        currentlySelected: Avatar(imageName: "avatar-tiger"),

        onDismiss: {},

        avatarSelection: { _ in }

    )



    return AvatarSelectionGridView(viewModel: viewModel)

}
