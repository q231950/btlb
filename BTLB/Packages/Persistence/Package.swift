// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Persistence",
            targets: ["Persistence"]),
    ],
    dependencies: [
        .package(path: "../LibraryCore"),
        .package(path: "../Localization"),
    ],
    targets: [
        .target(
            name: "Persistence",
            dependencies: ["LibraryCore", "Localization"]),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence"]),
    ]
)
