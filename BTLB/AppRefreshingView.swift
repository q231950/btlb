import UIKit

class AppRefreshingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // ... rest of initialization ...
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // ... rest of initialization ...
    }

    func greeting(name: String) {
        print("Hey \(name)")
    }
}
