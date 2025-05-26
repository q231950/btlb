// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Charges",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Charges",
            targets: ["Charges"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/architecture-x", .upToNextMajor(from: "0.0.3")),
        .package(path: "../Accounts"),
        .package(path: "../LibraryCore"),
        .package(path: "../LibraryUI"),
        .package(path: "../Localization"),
        .package(path: "../Persistence")
    ],
    targets: [
        .target(
            name: "Charges",
            dependencies: [
                .product(name: "ArchitectureX", package: "architecture-x"),
                "Accounts",
                "LibraryCore",
                "LibraryUI",
                "Localization",
                "Persistence"
            ]),
        .testTarget(
            name: "ChargesTests",
            dependencies: ["Charges"]),
    ]
)
