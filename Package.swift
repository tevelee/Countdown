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
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.4.3")
    ],
    targets: [
        .systemLibrary(name: "Dictionary"),
        .executableTarget(
            name: "Countdown",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                "SwiftSoup",
                "Dictionary"
            ]
        ),
        .testTarget(
            name: "CountdownTests",
            dependencies: ["Countdown"]
        ),
    ]
)
