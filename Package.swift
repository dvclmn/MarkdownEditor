// swift-tools-version:5.9

import PackageDescription

let localPackagesRoot = "/Users/dvclmn/Apps/_ Swift Packages"

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
    
    .package(url: "https://github.com/ChimeHQ/Neon.git", branch: "main"),
    .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.8.1"),
//    .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.1.4"),
    .package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown.git", branch: "split_parser"),
    .package(name: "TextCore", path: "\(localPackagesRoot)/TextCore"),
    .package(name: "Helpers", path: "\(localPackagesRoot)/SwiftCollection/Helpers"),
    
    
  ],
  targets: [
    .target(
      name: "MarkdownEditor",
      dependencies: [
        "Helpers",
        "TextCore",
        "Rearrange",
//        "STTextKitPlus",
        "Neon",
        .product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableExperimentalFeature("StrictConcurrency"),
        .enableUpcomingFeature("BareSlashRegexLiterals")
      ]
      
    ),
    .testTarget(
      name: "MarkdownEditorTests",
      dependencies: ["MarkdownEditor", "Helpers", "TextCore"]),
    
  ]
)
