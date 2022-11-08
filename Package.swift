// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Countdown",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(
            name: "Countdown",
            targets: ["Countdown"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "Countdown",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]),
        .testTarget(
            name: "CountdownTests",
            dependencies: ["Countdown"]
        ),
    ]
)
