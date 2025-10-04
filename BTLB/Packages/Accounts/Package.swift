// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Accounts",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Accounts",
            targets: ["Accounts"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../Libraries"),
        .package(path: "../LibraryCore"),
        .package(path: "../LibraryUI"),
        .package(path: "../Localization"),
        .package(path: "../Persistence"),
        .package(path: "../Mocks")
    ],
    targets: [
        .target(
            name: "Accounts",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "Libraries",
                "LibraryCore",
                "LibraryUI",
                "Localization",
                "Mocks",
                "Persistence"
            ]),
        .testTarget(
            name: "AccountsTests",
            dependencies: ["Accounts", "Mocks"]),
    ]
)
