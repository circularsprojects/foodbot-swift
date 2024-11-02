// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "foodbot-swift",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/DDBKit/DDBKit", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "foodbot-swift",
            dependencies: [
                .product(name: "DDBKit", package: "DDBKit"),
                .product(name: "Database", package: "DDBKit"),
                .product(name: "DDBKitUtilities", package: "DDBKit"),
                .product(name: "DDBKitFoundation", package: "DDBKit"),
            ]
        ),
    ]
)
