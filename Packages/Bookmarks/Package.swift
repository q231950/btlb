// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Bookmarks",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Bookmarks",
            targets: ["Bookmarks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../LibraryCore"),
        .package(path: "../LibraryUI"),
        .package(path: "../Localization"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "Bookmarks",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "LibraryCore",
                "LibraryUI",
                "Localization",
                "Persistence"
            ]),
        .testTarget(
            name: "BookmarksTests",
            dependencies: ["Bookmarks"]),
    ]
)
