// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Libraries",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Libraries",
            targets: ["Libraries"]),
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
            name: "Libraries",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "LibraryCore",
                "LibraryUI",
                "Localization",
                "Persistence"
            ]),
        .testTarget(
            name: "LibrariesTests",
            dependencies: ["Libraries"]),
    ]
)
