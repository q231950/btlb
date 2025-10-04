// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BTLBIntents",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "BTLBIntents",
            targets: ["BTLBIntents"]),
    ],
    dependencies: [
        .package(path: "../LibraryCore"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "BTLBIntents",
            dependencies: [
                "LibraryCore",
                "Persistence"
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "BTLBIntentsTests",
            dependencies: ["BTLBIntents"]),
    ]
)
