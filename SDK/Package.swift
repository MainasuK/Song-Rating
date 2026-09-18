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
        // Pinned to a tag on our fork rather than `branch: "master"` on the upstream
        // repo: a branch dependency is not reproducible and makes CI (Xcode Cloud) ask
        // for credentials to re-resolve it on every build.
        //
        // The fork's `2.4.1` points at the commit this project had been pinning via
        // `master` (6f2603c, 2022-10-12). Upstream's newest tag is 2.4.0 (2019), so it
        // could not be used without dropping three years of fixes.
        // Upstream also moved to cocoabits/MASShortcut and is now archived.
        .package(url: "https://github.com/MainasuK/MASShortcut.git", exact: "2.4.1"),
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
