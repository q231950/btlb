// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Mocks",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Mocks",
            targets: ["Mocks"]),
    ],
    dependencies: [
        .package(path: "../LibraryCore"),
        .package(path: "../Persistence"),
    ],
    targets: [
        .target(
            name: "Mocks",
            dependencies: [
                "LibraryCore",
                "Persistence"
            ])
    ]
)
