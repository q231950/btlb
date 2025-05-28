import SwiftUI

import ArchitectureX

public class OpenSourceSectionCoordinator: Coordinator {
    public var router: Router?
    
    public init(router: Router? = nil) {
        self.router = router
    }
    
    public var contentView: some View {
        OpenSourceSectionView()
    }
}
