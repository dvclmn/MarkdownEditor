// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "MarkdownEditor",
    platforms: [
        .iOS("17.0"),
        .macOS("14.0")
    ],
    products: [
        .library(
            name: "MarkdownEditor",
            targets: ["MarkdownEditor"]
        )
    ],
    dependencies: [
            .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
//            .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
            .package(name: "TestStrings", path: "../TestStrings"),
            .package(name: "Networking", path: "../Networking")
            
        ],
    targets: [
        .target(
            name: "MarkdownEditor",
            dependencies: ["TestStrings", "Highlightr", "Networking"]
        )
    ]
)

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        .unsafeFlags([
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
            "-enable-bare-slash-regex",
        ])
    )
}
