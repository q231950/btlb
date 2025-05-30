//
//  AccountDecorationEditView.swift
//
//
//  Created by Martin Kim Dung-Pham on 03.08.23.
//

import Combine
import CoreData
import SwiftUI

import Libraries
import LibraryCore
import LibraryUI
import Localization
import Utilities

/// Allows editing of decorative properties (non login relevant like credentials and library) of an account like avatar and display name
struct AccountDecorationEditView<Model: AccountEditViewModeling>: View where Model: ObservableObject {

    @ObservedObject private var viewModel: Model
    @State private var showsDeleteConfirmation = false
    @State var isShowingAvatarSelection = false
    @FocusState private var displayNameFieldIsFocused: Bool
    private let onSave: () -> Void

    public init(_ viewModel: Model, onSave: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        AvatarView(viewModel.avatarName, selected: true) {
                            isShowingAvatarSelection = true
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    ValueEditView(viewModel.displayNameValueEditViewModel)
                        .textContentType(.nickname)
                        .focused($displayNameFieldIsFocused)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            Spacer()
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $isShowingAvatarSelection) {
            avatarSelectionView
        }
        .task {
            viewModel.updateValues()
        }
        .onAppear {
            displayNameFieldIsFocused = true
        }
        .onDisappear {
            viewModel.save()

            onSave()
        }
        .navigationTitle(Text(Localization.EditAccount.DisplayName.title))
    }

    @ViewBuilder private var avatarSelectionView: some View {
        NavigationView {
            AvatarSelectionCoordinator(currentlySelected: viewModel.avatarName, onCancel: {
                isShowingAvatarSelection = false
            }) { avatar in
                withAnimation(.smooth) {
                    viewModel.updateAvatarName(avatar)
                    isShowingAvatarSelection = false
                }
            }
            .contentView
        }
    }
}

#if DEBUG
#Preview {
    let viewModel = AccountEditViewModelMock()

    NavigationView {
        AccountDecorationEditView(viewModel) {
        }
    }
}

class AccountEditViewModelMock: ObservableObject, AccountEditViewModeling {
    @Published var avatarName: String? = "avatar-cat"

    func updateAvatarName(_ avatarName: String?) {
        self.avatarName = avatarName
    }

    @Published var displayNameValueEditViewModel: ValueEditViewModel = .init(title: "abc", observedValue: ObservedValue(onSave: { old, new in

    }, onUpdate: { updated in

    }))

    func updateValues() {}
    func save() {}
}
#endif
