//
//  VersionNumberProvider.swift
//  BTLB
//
//  Created by Martin Kim Dung-Pham on 22.01.20.
//  Copyright © 2020 neoneon. All rights reserved.
//

import Foundation

public struct VersionNumberProvider {

    /// Get the version and build number in a combined string such as `2.5.0 (87)`
    public static var versionString: String {
        "\(versionNumber) (\(buildNumber))"
    }

    public static var gitString: String {
        "\(gitBranch) - \(gitCommit)"
    }

    public static var gitCommit: String {
        (Bundle.main.infoDictionary?["GitCommit"] as? String) ?? "unknown"
    }

    static var gitBranch: String {
        (Bundle.main.infoDictionary?["GitBranch"] as? String) ?? "unknown"
    }

    private static var versionNumber: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
    }

    private static var buildNumber: String {
        (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "unknown"
    }

}
