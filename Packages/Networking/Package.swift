// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/q231950/the-stubborn-network.git", branch: "main"),
        .package(path: "../NetworkShim"),
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "StubbornNetwork", package: "the-stubborn-network"),
                "NetworkShim"
            ]),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]),
    ]
)
