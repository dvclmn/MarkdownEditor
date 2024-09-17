// swift-tools-version:5.10

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
    
//    .package(url: "https://github.com/ChimeHQ/Neon.git", branch: "main"),
    .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.8.1"),
//    .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.1.4"),
//    .package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown.git", branch: "split_parser"),
    .package(url: "https://github.com/dvclmn/TextCore.git", branch: "main"),
    .package(url: "https://github.com/dvclmn/Collection.git", branch: "main"),
    .package(url: "https://github.com/dvclmn/Wrecktangle", branch: "main")
    
    
  ],
  targets: [
    .target(
      name: "MarkdownEditor",
      dependencies: [
        .product(name: "Wrecktangle", package: "Wrecktangle"),
        .product(name: "BaseHelpers", package: "Collection"),
        "TextCore",
        "Rearrange",
//        "STTextKitPlus",
//        "Neon",
//        .product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
        .enableUpcomingFeature("BareSlashRegexLiterals")
      ]
      
    ),
    .testTarget(
      name: "MarkdownEditorTests",
      dependencies: [
        "MarkdownEditor",
        .product(name: "BaseHelpers", package: "Collection"),
        "TextCore"
      ]
    ),
    
  ]
)
