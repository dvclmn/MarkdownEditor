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
              "MarkdownEditor",
              "Syntax"
            ]
        )
    ],
    dependencies: [
//            .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
//            .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.8.1"),
            .package(name: "TestStrings", path: "../TestStrings"),
//            .package(name: "Networking", path: "../Networking"),
//            .package(name: "Utilities", path: "/Users/dvclmn/Apps/_ Swift Packages/Utilities"),
            .package(name: "Helpers", path: "/Users/dvclmn/Apps/_ Swift Packages/Helpers")
            
        ],
    targets: [
        .target(
            name: "MarkdownEditor",
            dependencies: ["TestStrings", "Syntax", "Helpers"]
        ),
        .target(
          name: "Syntax",
          dependencies: []
        ),
        .testTarget(
          name: "MarkdownEditorTests",
          dependencies: ["MarkdownEditor", "Syntax"]),

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
