// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LibraryUI",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "LibraryUI",
            targets: ["LibraryUI"]),
    ],
    dependencies: [
        .package(path: "../LibraryCore"),
        .package(path: "../Persistence"),
        .package(path: "../Localization"),
        .package(path: "../Utilities")
    ],
    targets: [
        .target(
            name: "LibraryUI",
            dependencies: ["LibraryCore", "Localization", "Persistence", "Utilities"]),
        .testTarget(
            name: "LibraryUITests",
            dependencies: ["LibraryUI"]),
    ]
)
