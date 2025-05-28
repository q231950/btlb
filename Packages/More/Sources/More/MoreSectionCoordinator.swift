import Foundation
import SwiftUI

import ArchitectureX

import Accounts
import LibraryCore
import Localization
import Persistence
import BTLBSettings

public final class MoreSectionCoordinator: Coordinator {
    public var router: Router? = Router()
    private let entries: [Entry]

    public init(entries: [Entry]) {
        self.entries = entries
    }

    public var contentView: some View {
        let viewModel = MoreSectionViewModel(entries: entries)

        return MoreList(viewModel: viewModel)
            .navigationTitle(Localization.Titles.more)
            .navigationBarTitleDisplayMode(.large)
    }
}

struct MoreList: View {
    @ObservedObject var viewModel: MoreSectionViewModel
    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(viewModel.entries) { entry in
                    NavigationLink(value: entry) {
                        Text(entry.title)
                    }
                }
            }
            .navigationDestination(for: Entry.self) { entry in
                switch entry {
                case .about:
                    AboutSectionCoordinator().contentView
                case .accounts:
                    let listViewModel = AccountListViewModel(dataStackProvider: DataStackProvider.shared) {
                        path.removeLast()
                    }

                    AccountList(viewModel: listViewModel)
                case .settings(let settingsService):
                    SettingsSectionCoordinator(settingsService: settingsService).contentView
                case .openSource:
                    OpenSourceSectionView()
                }
            }
        }
    }
}

class MoreSectionViewModel: ObservableObject {
    @Published var entries: [Entry]

    init(entries: [Entry]) {
        self.entries = entries
    }
}

public enum Entry: Hashable, Identifiable {
    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: String {
        title
    }
    case about
    case accounts
    case settings(any LibraryCore.SettingsService)
    case openSource

    var title: String {
        switch self {
        case .about:
            return Localization.Titles.about
        case .accounts:
            return Localization.Titles.accounts
        case .settings:
            return Localization.Titles.settings
        case .openSource:
            return "Open Source"
        }
    }
}

//#Preview {
//    NavigationStack {
//        MoreSectionCoordinator(entries: [.accounts, .about])
//            .contentView
//    }
//}
