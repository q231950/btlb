// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Bookmarks",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Bookmarks",
            targets: ["Bookmarks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../BTLBSettings"),
        .package(path: "../LibraryCore"),
        .package(path: "../Libraries"),
        .package(path: "../LibraryUI"),
        .package(path: "../Localization"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "Bookmarks",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "BTLBSettings",
                "LibraryCore",
                "Libraries",
                "LibraryUI",
                "Localization",
                "Persistence"
            ]),
        .testTarget(
            name: "BookmarksTests",
            dependencies: ["Bookmarks"]),
    ]
)
