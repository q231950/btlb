//
//  ValueEditView.swift
//  
//
//  Created by Martin Kim Dung-Pham on 12.08.23.
//

import Combine
import Foundation
import SwiftUI

import Utilities

import LibraryCore

public class LibrarySelectionEditViewModel: ObservableObject {
    @Published public var selectedLibraryIdentifier: String?

    private var cancellables = Set<AnyCancellable>()

    public init(selectedLibraryIdentifier: String?, observedValue: ObservedValue) {
        self.selectedLibraryIdentifier = selectedLibraryIdentifier

        $selectedLibraryIdentifier.sink { library in
            observedValue.text = library ?? "UNKNOWN LIBRARY"
        }.store(in: &cancellables)

        observedValue.savedText.sink { value in
            self.selectedLibraryIdentifier = value
        }.store(in: &cancellables)
    }
}

public class ValueEditViewModel: ObservableObject {

    let title: String
    let isSecure: Bool
    @Published var value: String = ""

    private var cancellables = Set<AnyCancellable>()

    public init(title: String, isSecure: Bool = false, observedValue: ObservedValue) {
        self.title = title
        self.isSecure = isSecure

        $value.sink { newValue in
            observedValue.text = newValue
        }.store(in: &cancellables)

        observedValue.savedText.sink { value in
            Task { @MainActor in
                self.value = value
            }
        }.store(in: &cancellables)
    }
}

public struct ValueEditView: View {

    @ObservedObject var viewModel: ValueEditViewModel
    @FocusState private var focus: Field?
    let editable: Bool

    enum Field: Hashable {
        case value
    }

    public init(_ viewModel: ValueEditViewModel, editable: Bool = true) {
        self.viewModel = viewModel
        self.editable = editable
    }

    public var body: some View {
        VStack {
            Text(viewModel.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if viewModel.isSecure {
                    SecureField(viewModel.title, text: $viewModel.value)
                } else {
                    TextField(viewModel.title, text: $viewModel.value, prompt: Text(viewModel.title))
                        .disabled(!editable)
                }
            }
            .frame(maxWidth: .infinity)
            .font(.body.italic())
            .focused($focus, equals: .value)
        }
    }
}

#Preview {
    let viewModel = ValueEditViewModel(title: "abc", observedValue: .init(onSave: { old, new in
        print("old: \(old) - new: \(new)")
    }, onUpdate: { newValue in
        print("onUpdate: \(newValue)")
    }))

    ValueEditView(viewModel, editable: true)
}
