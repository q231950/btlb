import Foundation
import SwiftUI

import LibraryUI
import Localization

public struct OpenSourceSectionView: View {

    public init() {}

    @Environment(\.locale) var locale

    public var body: some View {
        List {
            Section {
                Text("OPEN_SOURCE_DESCRIPTION", bundle: .module)
                    .listRowSeparator(.hidden)
            }
            
            repositorySection
        }
        .listStyle(.plain)
        .navigationTitle(String(localized: "Open Source", bundle: .module, locale: locale))
    }

    // MARK: Repository

    private var repositorySection: some View {
        Section {
            HStack {
                Link(String(localized: "GitHub Repository", bundle: .module, locale: locale), destination: URL(string: "https://github.com/q231950/BTLB")!)
                Image(systemName: "arrow.up.forward")
            }

            HStack {
                Link(
                    String(localized: "License", bundle: .module, locale: locale),
                    destination: URL(string: "https://opensource.org/license/gpl-3-0")!
                )
                Image(systemName: "arrow.up.forward")
            }

            HStack {
                Link(
                    VersionNumberProvider.gitString,
                    destination: URL(string: "https://github.com/q231950/btlb/commit/\(VersionNumberProvider.gitCommit)")!
                )
                Image(systemName: "arrow.up.forward")
            }
        } header: {
            ItemView(title: String(localized: "Links", bundle: .module, locale: locale))
        }
    }
}

struct OpenSourceSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OpenSourceSectionView()
        }
    }
}
