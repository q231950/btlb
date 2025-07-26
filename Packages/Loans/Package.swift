// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Loans",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Loans",
            targets: ["Loans"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../Accounts"),
        .package(path: "../Bookmarks"),
        .package(path: "../BTLBSettings"),
        .package(path: "../LibraryCore"),
        .package(path: "../LibraryUI"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "Loans",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "Accounts",
                "BTLBSettings",
                "Bookmarks",
                "LibraryCore",
                "LibraryUI",
                "Persistence"
            ]),
        .testTarget(
            name: "LoansTests",
            dependencies: ["Loans"]),
    ]
)
