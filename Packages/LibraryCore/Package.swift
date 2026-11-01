// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LibraryCore",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "LibraryCore",
            targets: ["LibraryCore"]),
    ],
    dependencies: [
        .package(path: "../Localization"),
    ],
    targets: [
        .target(
            name: "LibraryCore",
            dependencies: [
                "Localization",
            ]),
        .testTarget(
            name: "LibraryCoreTests",
            dependencies: [
                "LibraryCore",
            ]),
    ]
)
