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
            
            Section {
                Link("GitHub Repository", destination: URL(string: "https://github.com/q231950/BTLB")!)
                Link(
                    String(localized: "License", bundle: .module, locale: locale),
                    destination: URL(string: "https://opensource.org/license/gpl-3-0")!
                )
            } header: {
                Text(String(localized: "Links", bundle: .module, locale: locale))
            }
        }
        .listStyle(.plain)
        .navigationTitle(String(localized: "Open Source", bundle: .module, locale: locale))
    }
}

struct OpenSourceSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OpenSourceSectionView()
        }
    }
}
