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
    
    .package(url: "https://github.com/ChimeHQ/Neon", branch: "main"),
    .package(url: "https://github.com/ChimeHQ/Rearrange", from: "1.8.1"),
//    .package(url: "https://github.com/krzyzanowskim/STTextKitPlus.git", from: "0.1.4"),
    .package(url: "https://github.com/tree-sitter-grammars/tree-sitter-markdown", branch: "split_parser"),
    .package(url: "https://github.com/dvclmn/TextCore", branch: "main"),
    .package(url: "https://github.com/dvclmn/Collection", branch: "main"),
//    .package(url: "https://github.com/dvclmn/Wrecktangle.git", branch: "main")
    
    
  ],
  targets: [
    .target(
      name: "MarkdownEditor",
      dependencies: [
//        "Wrecktangle",
        .product(name: "BaseHelpers", package: "Collection"),
        "TextCore",
        "Rearrange",
//        "STTextKitPlus",
        "Neon",
        .product(name: "TreeSitterMarkdown", package: "tree-sitter-markdown"),
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

