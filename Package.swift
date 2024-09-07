// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "MarkdownEditor",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(
      name: "MarkdownEditor",
      targets: ["MarkdownEditor"]
    )
  ],
  dependencies: [
    
    .package(url: "https://github.com/ChimeHQ/Neon.git", from: "0.6.0"),
    .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.8.1"),
    .package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown.git", branch: "split_parser"),
    .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.1.4"),
    .package(name: "TextCore", path: "../TextCore"),
    .package(name: "Helpers", path: "../SwiftCollection/Helpers"),
    
    
  ],
  targets: [
    .target(
      name: "MarkdownEditor",
      dependencies: [
        "Helpers",
        "TextCore",
        "STTextKitPlus",
        "Rearrange",
        "Neon",
//        .product(name: "TreeSitterClient", package: "Neon"),
//        .product(name: "RangeState", package: "Neon"),
        .product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
      ]
      
    ),
    .testTarget(
      name: "MarkdownEditorTests",
      dependencies: ["MarkdownEditor", "Helpers", "TextCore"]),
    
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
