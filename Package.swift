// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "punic",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "punic",
            targets: ["punic"])
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.5.0"),
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "6.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.2"),
        .package(url: "https://github.com/phimage/XcodeProjKit.git", from: "2.1.5")
    ],
    targets: [
        .target(
            name: "punic",
            dependencies: [
                "AEXML",
                "FileKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XcodeProjKit"])
    ]
)

