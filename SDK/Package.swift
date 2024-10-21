// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDK",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SDK",
            targets: ["SDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/shpakovski/MASShortcut.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "SDK",
            dependencies: [
                .product(name: "MASShortcut", package: "MASShortcut")
            ]),
        .testTarget(
            name: "SDKTests",
            dependencies: ["SDK"]),
    ]
)
