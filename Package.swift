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
    
    .package(url: "https://github.com/raspu/Highlightr.git", from: "2.2.1"),
//    .package(url: "https://github.com/ChimeHQ/Neon.git", branch: "main"),
    .package(url: "https://github.com/ChimeHQ/Rearrange.git", from: "1.8.1"),
    .package(url: "https://github.com/ChimeHQ/Glyph.git", branch: "main"),
//    .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.1.4"),
//    .package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown.git", branch: "split_parser"),
    .package(url: "https://github.com/dvclmn/TextCore.git", branch: "main"),
    .package(url: "https://github.com/dvclmn/Collection.git", branch: "main"),
    .package(url: "https://github.com/dvclmn/Wrecktangle.git", branch: "main")
    
  ],
  targets: [
    .target(
      name: "MarkdownEditor",
      dependencies: [
        "Wrecktangle",
        "TextCore",
        "Rearrange",
        "Glyph",
//        "STTextKitPlus",
        "Highlightr",
        
//        "Neon",
//        .product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
        .product(name: "BaseHelpers", package: "Collection"),
        .product(name: "BaseStyles", package: "Collection"),
        .product(name: "Utilities", package: "Collection"),
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


let swiftSettings: [SwiftSetting] = [
  .enableExperimentalFeature("StrictConcurrency"),
  .enableUpcomingFeature("DisableOutwardActorInference"),
  .enableUpcomingFeature("InferSendableFromCaptures"),
  .enableUpcomingFeature("BareSlashRegexLiterals"),
]

for target in package.targets {
  var settings = target.swiftSettings ?? []
  settings.append(contentsOf: swiftSettings)
  target.swiftSettings = settings
}

