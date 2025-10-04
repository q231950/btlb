// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NetworkShim",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "NetworkShim",
            targets: ["NetworkShim"]),
    ],
    targets: [
        .target(
            name: "NetworkShim"
	)
    ]
)
