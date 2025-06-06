import Foundation
import SwiftUI

import LibraryUI
import Localization

public struct OpenSourceSectionView: View {

    public init() {}

    @Environment(\.locale) var locale
    @Environment(\.openURL) var openUrl

    public var body: some View {
        List {
            description
                .listRowSeparator(.hidden)

            licenseSection
                .listSectionSeparator(.hidden)

            repositorySection
                .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(String(localized: "Open Source", bundle: .module, locale: locale))
    }

    private var description: some View {
        Text("OPEN_SOURCE_DESCRIPTION", bundle: .module)
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
                    VersionNumberProvider.gitString,
                    destination: URL(string: "https://github.com/q231950/btlb/commit/\(VersionNumberProvider.gitCommit)")!
                )
                Image(systemName: "arrow.up.forward")
            }
        } header: {
            ItemView(title: String(localized: "Links", bundle: .module, locale: locale))
        }
    }

    private var licenseSection: some View {
        Section {

        } header: {
            HStack {
                ItemView(title: String(localized: "License", bundle: .module, locale: locale))

                Spacer()

                Button {
                    openUrl(URL(string: "https://opensource.org/license/gpl-3-0")!)
                } label: {
                    Text("GPL-3.0")
                        .bold()
                        .padding(10)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                }
            }
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
