// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TestUtilitiesCore",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "TestUtilitiesCore",
            targets: ["TestUtilitiesCore"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TestUtilitiesCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TestUtilitiesCoreTests",
            dependencies: ["TestUtilitiesCore"]),
    ]
)
