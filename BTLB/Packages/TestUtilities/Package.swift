// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TestUtilities",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "TestUtilities",
            targets: ["TestUtilities"]),
    ],
    dependencies: [
        .package(path: "../NetworkShim"),
        .package(path: "../LibraryCore"),
        .package(path: "../TestUtilitiesCore")
    ],
    targets: [
        .target(
            name: "TestUtilities",
            dependencies: [
                "LibraryCore",
                "NetworkShim",
                "TestUtilitiesCore"
            ]
        ),
        .testTarget(
            name: "TestUtilitiesTests",
            dependencies: ["TestUtilities"]),
    ]
)
