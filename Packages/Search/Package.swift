// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Search",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Search",
            targets: ["Search"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../LibraryCore"),
        .package(path: "../Persistence"),
        .package(path: "../Libraries"),
        .package(path: "../Localization"),
        .package(path: "../Mocks"),
        .package(path: "../TestUtilitiesCore")
    ],
    targets: [
        .target(
            name: "Search",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "LibraryCore",
                "Libraries",
                "Localization",
                "Persistence"
            ]),
        .testTarget(
            name: "SearchTests",
            dependencies: ["Search", "Mocks", "TestUtilitiesCore"]),
    ]
)
