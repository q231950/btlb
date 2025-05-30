// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BTLBSettingsPackage",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [
        .library(
            name: "BTLBSettings",
            targets: ["BTLBSettings"]),
    ],
    dependencies:        [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../LibraryCore"),
        .package(path: "../LibraryUI"),
        .package(path: "../Localization"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "BTLBSettings",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "LibraryCore",
                "LibraryUI",
                "Localization",
                "Persistence"
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "BTLBSettingsTests",
            dependencies: ["BTLBSettings"]),
    ]
)
