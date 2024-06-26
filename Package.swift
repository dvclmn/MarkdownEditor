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
//            .package(name: "Highlightr", path: "../Highlightr"),
            .package(name: "TestStrings", path: "../TestStrings"),
        ],
    targets: [
        .target(
            name: "MarkdownEditor",
            dependencies: ["Highlightr", "TestStrings"]
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
