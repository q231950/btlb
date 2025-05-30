// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Localization",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [
        .library(
            name: "Localization",
            targets: ["Localization"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Localization",
            dependencies: []),
        .testTarget(
            name: "LocalizationTests",
            dependencies: ["Localization"]),
    ]
)
