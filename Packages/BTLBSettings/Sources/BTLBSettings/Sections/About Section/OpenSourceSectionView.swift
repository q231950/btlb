import Foundation
import SwiftUI

import LibraryUI
import Localization

struct OpenSourceSectionView: View {
    var body: some View {
        List {
            Section {
                Text("OPEN_SOURCE_DESCRIPTION", bundle: .module)
                    .listRowSeparator(.hidden)
            }
            
            Section {
                Link("GitHub Repository", destination: URL(string: "https://github.com/example/repository")!)
                Link("License", destination: URL(string: "https://opensource.org/licenses/MIT")!)
            } header: {
                Text("Links")
            }
        }
        .listStyle(.plain)
        .navigationTitle("Open Source")
    }
}

struct OpenSourceSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OpenSourceSectionView()
        }
    }
}
