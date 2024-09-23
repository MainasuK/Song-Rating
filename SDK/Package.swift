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
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "ArkanaKeys", path: "../dependencies/ArkanaKeys"),
        .package(url: "https://github.com/shpakovski/MASShortcut.git", branch: "master"),
        .package(url: "https://github.com/MainasuK/DiscordGameSDK-Wrapper.git", branch: "main"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "0.17.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SDK",
            dependencies: [
                .product(name: "ArkanaKeys", package: "ArkanaKeys"),
                .product(name: "MASShortcut", package: "MASShortcut"),
                .product(name: "CDiscordGameSDK", package: "DiscordGameSDK-Wrapper"),
                .product(name: "AWSS3", package: "aws-sdk-swift"),
            ]),
        .testTarget(
            name: "SDKTests",
            dependencies: ["SDK"]),
    ]
)
