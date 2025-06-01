// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "punic",
    products: [
        .executable(name: "punic", targets: ["punic"])
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.7.0"),
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "6.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.1"),
        .package(url: "https://github.com/phimage/XcodeProjKit.git", from: "4.0.0")
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

