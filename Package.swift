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
            targets: [
              "MarkdownEditor"
            ]
        )
    ],
    dependencies: [
//            .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
//            .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.8.1"),
            .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.1.4"),
            .package(name: "Styles", path: "../Styles"),
            .package(name: "Networking", path: "../Networking"),
            .package(name: "Helpers", path: "../Helpers")
            
        ],
    targets: [
        .target(
            name: "MarkdownEditor",
            dependencies: ["Helpers", "Styles", "Networking", "STTextKitPlus"]
        ),
//        .target(
//          name: "Syntax",
//          dependencies: []
//        ),
        .testTarget(
          name: "MarkdownEditorTests",
          dependencies: ["MarkdownEditor"]),

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
