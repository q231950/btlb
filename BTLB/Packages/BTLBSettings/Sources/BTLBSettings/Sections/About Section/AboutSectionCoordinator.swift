import SwiftUI

import ArchitectureX

public class AboutSectionCoordinator: Coordinator {

    public var router: Router?

    public init(router: Router? = nil) {
        self.router = router
    }

    public var contentView: some View {
        AboutSectionView(libraries: libraries)
    }

    private var libraries: AboutSectionLibraryList {
        get {
            guard let path = Bundle.module.path(forResource: "libraries", ofType: "json") else {
                return AboutSectionLibraryList(libraries: [])
            }

            let url = URL(filePath: path)

            guard let data = try? Data(contentsOf: url),
                  let list = try? JSONDecoder().decode(AboutSectionLibraryList.self, from: data) else {
                return AboutSectionLibraryList(libraries: [])
            }

            return list
        }
    }
}
