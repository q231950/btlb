// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Utilities",
            targets: ["Utilities"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../LibraryCore"),
        .package(path: "../Localization"),
        .package(path: "../Networking"),
        .package(path: "../Persistence"),
        .package(path: "../TestUtilities"),
        .package(path: "../Mocks"),
        .package(url: "https://github.com/q231950/rorschach", branch: "support-async-assertions"),
    ],
    targets: [
        .target(
            name: "Utilities",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "LibraryCore",
                "Localization",
                "Networking",
                "Persistence"],
            resources: [.process("Resources/RequestBodyTemplates")]),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: [
                "Mocks",
                "Utilities",
                "TestUtilities",
                .product(name: "Rorschach", package: "rorschach"),
            ]),
    ]
)
