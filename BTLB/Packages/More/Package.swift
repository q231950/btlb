// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "More",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "More",
            targets: ["More"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../Accounts"),
        .package(path: "../LibraryCore"),
        .package(path: "../LibraryUI"),
        .package(path: "../Localization"),
        .package(path: "../BTLBSettings"),
        .package(path: "../Persistence"),
    ],
    targets: [
        .target(
            name: "More",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "Accounts",
                "LibraryCore",
                "LibraryUI",
                "Localization",
                "Persistence",
                "BTLBSettings",
            ], resources: [.process("Resources")]),
        .testTarget(
            name: "MoreTests",
            dependencies: ["More"]),
    ]
)
