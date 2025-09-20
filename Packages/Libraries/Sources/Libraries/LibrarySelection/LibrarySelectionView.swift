//
//  LibrarySelectionView.swift
//
//
//  Created by Martin Kim Dung-Pham on 03.11.23.
//

import CoreData
import Combine
import Foundation
import SwiftUI

import LibraryCore
import class Persistence.DataStackProvider
import class Persistence.PersistentContainer

public struct LibrarySelectionView<L: LibraryCore.Library>: View {

    @ObservedObject private var viewModel: LibrarySelectionViewModel<L>

    init(viewModel: LibrarySelectionViewModel<L>) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section {
                Text(viewModel.descriptiveText, bundle: .module)
                    .padding(.bottom)
            }
            .listSectionSeparator(.hidden)

            Section {
                ForEach(viewModel.filteredLibraries, id: \.self.identifier) { library in
                    Button(action: {
                        viewModel.librarySelection(library)
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(library.name ?? "")
                                    .font(.headline)

                                if library.identifier == viewModel.currentlySelectedIdentifier {
                                    Spacer()
                                    Image(systemName: "building.columns.circle")
                                }
                            }
 
                            Text(library.subtitle ?? "")
                                .font(.subheadline)
                        }
                    }
                    .disabled(viewModel.isDisabled(library))
                    .listRowSeparator(.hidden)
                }
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.filterText)
    }
}

public enum LibrarySelectionType {
    case search
    case login
}

public class LibrarySelectionViewModel<L: LibraryCore.Library>: ObservableObject {
    @Published var filterText = ""
    @Published var filteredLibraries = [L]()
    @Published var libraries = [L]()
    private let persistentContainer: PersistentContainer?
    let selectionType: LibrarySelectionType
    let currentlySelectedIdentifier: String?
    let librarySelection: (_ selectedLibrary: L) -> ()
    private var bag: Set<AnyCancellable> = []

    public var descriptiveText: LocalizedStringKey {
        switch selectionType {
        case .search: "Currently Search supports libraries of _Stiftung Hamburger Öffentliche Bücherhallen_ and _Gemeinsamer Bibliotheksverbund_. Please select the library to search in."
        case .login: "Currently you can login to libraries of _Stiftung Hamburger Öffentliche Bücherhallen_ and _Gemeinsamer Bibliotheksverbund_. Please select the library to login to."
        }
    }

    init(for selectionType: LibrarySelectionType,
         persistentContainer: PersistentContainer?,
         currentlySelected identifier: String? = nil,
         librarySelection: @escaping (_ selectedLibrary: L) -> ()) {
        self.selectionType = selectionType
        self.persistentContainer = persistentContainer
        self.currentlySelectedIdentifier = identifier
        self.librarySelection = librarySelection

        $filterText.sink { [weak self] text in
            guard !text.isEmpty else { return }

            self?.filteredLibraries = self?.libraries.filter({ library in
                library.name?.lowercased().contains(text.lowercased()) ?? false ||
                library.subtitle?.lowercased().contains(text.lowercased()) ?? false
            }) ?? []
        }.store(in: &bag)

        defer {
            fetchLibraries()
        }
    }

    func isDisabled(_ library: L) -> Bool {
        switch selectionType {
        case .search: !library.isAvailable
        case .login: !library.isAvailableForLogin
        }
    }

    fileprivate func fetchLibraries() {
        persistentContainer?.libraries(completion: { (result: Result<[L], Error>) in
            switch result {
            case .success(let libraries):
                print(libraries)
                self.libraries.insert(contentsOf: libraries, at: 0)
                self.filteredLibraries.insert(contentsOf: libraries, at: 0)
            case .failure(let error):
                assertionFailure(error.localizedDescription)
                break
            }
        })
    }
}

#Preview {
//    dataStackProvider.loadInMemory()

    LibrarySelectionView<LibraryStub>(viewModel: LibrarySelectionViewModel.stub)
}

private extension LibrarySelectionViewModel {

    @MainActor static var stub: LibrarySelectionViewModel {
        LibrarySelectionViewModel(for: .search, persistentContainer: DataStackProvider().persistentContainer, librarySelection: { library in
        })
    }
}

private class LibraryResourceMock {
    func libraries(completion: @escaping (Result<[LibraryMock], any Error>) -> Void) {
        completion(.success([LibraryMock(), LibraryMock()]))
    }
}

private class LibraryStub: LibraryCore.Library {
    
    var isAvailable: Bool { true }

    static func == (lhs: LibraryStub, rhs: LibraryStub) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    init() {}

    var name: String? = "Some Library"
    var subtitle: String? = "Some Subtitle"

    var libraryType: LibraryCore.LibraryType = .hamburgPublic

    var baseURL: String?
    var catalogUrl: String?

    var identifier: String? = UUID().uuidString
}

public final class LibraryMock: LibraryCore.Library {

    public init() {}

    public var name: String? = "Library \(["A", "B", "C"].randomElement() ?? "X")"
    public var subtitle: String?

    public var baseURL: String?
    public var catalogUrl: String?

    public var identifier: String? {
        "Mock Library Identifier \(name ?? "")"
    }

    public static func == (lhs: LibraryMock, rhs: LibraryMock) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
