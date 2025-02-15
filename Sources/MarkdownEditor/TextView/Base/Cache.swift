//
//  Cache.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/2/2025.
//

import AppKit

//final class MarkdownCache: Sendable {
//  static let shared = MarkdownCache()
//  private var cache = NSCache<NSString, NSAttributedString>()
//  private var processingQueue = DispatchQueue(
//    label: "com.banksia.markdown.processing", qos: .userInitiated)
//
//  func cachedText(
//    for key: String, process: @escaping (String) -> NSAttributedString
//  ) async -> NSAttributedString {
//    if let cached = cache.object(forKey: key as NSString) {
//      return cached
//    }
//
//    return await withCheckedContinuation { continuation in
//      processingQueue.async {
//        let processed = process(key)
//        self.cache.setObject(processed, forKey: key as NSString)
//        continuation.resume(returning: processed)
//      }
//    }
//  }
//
//  func invalidate(for key: String) {
//    cache.removeObject(forKey: key as NSString)
//  }
//}
//
//
//struct ProcessedMarkdown {
//  let attributedString: NSAttributedString
//  let timestamp: Date
//
//  static func process(
//    text: String,
//    configuration: EditorConfiguration
//  ) -> ProcessedMarkdown {
//    let store = NSMutableAttributedString(string: text)
//
//    /// Apply default attributes
//    let range = NSRange(location: 0, length: store.length)
//    store.setAttributes(configuration.defaultTypingAttributes, range: range)
//
//    /// Apply markdown styles
//    for syntax in Markdown.Syntax.allCases {
//      applySyntaxStyle(to: store, syntax: syntax, configuration: configuration)
//    }
//
//    // Apply code highlighting
//    //    highlightCodeBlocks(in: store, using: highlightr)
//
//    return ProcessedMarkdown(
//      attributedString: store,
//      timestamp: Date()
//    )
//  }
//
//  private static func applySyntaxStyle(
//    to backingStore: NSMutableAttributedString,
//    syntax: Markdown.Syntax,
//    configuration: EditorConfiguration
//  ) {
//    guard let pattern = syntax.nsRegex else { return }
//
//    processRegexMatches(
//      in: backingStore,
//      for: syntax,
//      using: pattern
//    ) { ranges in
//      /// Apply leading syntax attributes
//      backingStore.addAttributes(
//        syntax.syntaxAttributes(with: configuration).attributes,
//        range: ranges.leading
//      )
//
//      /// Apply content attributes
//      backingStore.addAttributes(
//        syntax.contentAttributes(with: configuration).attributes,
//        range: ranges.content
//      )
//
//      /// Apply closing syntax attributes
//      backingStore.addAttributes(
//        syntax.syntaxAttributes(with: configuration).attributes,
//        range: ranges.trailing
//      )
//    }
//  }
//
//  private static func processRegexMatches(
//    in backingStore: NSMutableAttributedString,
//    for syntax: Markdown.Syntax,
//    using pattern: NSRegularExpression,
//    applyAttributes: (MarkdownRanges) -> Void
//  ) {
//    let text = backingStore.string
//    let range = NSRange(location: 0, length: backingStore.length)
//
//    print("About to enumerate regex matches for syntax: \(syntax), pattern: \(pattern)")
//
//    pattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
//      guard let match = match else { return }
//      print("Match found: \(match.debugDescription)")
//
//      /// Create safe wrapper
//      guard let safeMatch = RegexMatch(match: match) else {
//        print("Failed to create RegexMatch wrapper")
//        return
//      }
//
//      /// Validate the full match range
//      guard safeMatch.fullRange.location + safeMatch.fullRange.length <= backingStore.length else {
//        print(
//          "Invalid match range: \(safeMatch.fullRange.debugDescription) for string length: \(backingStore.length)"
//        )
//        return
//      }
//
//      /// Process based on syntax type
//      do {
//        let ranges = try createRanges(for: syntax, from: safeMatch)
//        applyAttributes(ranges)
//      } catch let error {
//        print("Error processing \(syntax): \(error)")
//      }
//    }
//  }
//
//  private static func createRanges(
//    for syntax: Markdown.Syntax, from match: RegexMatch
//  ) throws -> MarkdownRanges {
//    switch syntax {
//      case .heading, .quoteBlock:
//        guard let leadingRange = match.capture(at: 1) else {
//          throw MarkdownRegexError.missingRequiredCapture(index: 1, syntax: syntax)
//        }
//        guard let contentRange = match.capture(at: 2) else {
//          throw MarkdownRegexError.missingRequiredCapture(index: 2, syntax: syntax)
//        }
//
//        return MarkdownRanges(
//          all: match.fullRange,
//          leading: leadingRange,
//          content: contentRange,
//          trailing: .zero
//        )
//
//      case .inlineCode, .strikethrough, .codeBlock, .highlight:
//        guard let leadingRange = match.capture(at: 1),
//          let contentRange = match.capture(at: 2),
//          let trailingRange = match.capture(at: 3)
//        else {
//          throw MarkdownRegexError.missingRequiredCapture(index: 3, syntax: syntax)
//        }
//
//        return MarkdownRanges(
//          all: match.fullRange,
//          leading: leadingRange,
//          content: contentRange,
//          trailing: trailingRange
//        )
//
//      case .link, .image:
//        guard let textOpenRange = match.capture(at: 1),
//          let textRange = match.capture(at: 2),
//          let urlOpenRange = match.capture(at: 3),
//          let urlRange = match.capture(at: 4),
//          let urlCloseRange = match.capture(at: 5)
//        else {
//          throw MarkdownRegexError.missingRequiredCapture(index: 5, syntax: syntax)
//        }
//
//        // Combine ranges for leading and trailing parts
//        let leadingRange = NSRange(
//          location: textOpenRange.location,
//          length: textOpenRange.length + textRange.length
//        )
//
//        let trailingRange = NSRange(
//          location: urlOpenRange.location,
//          length: urlOpenRange.length + urlRange.length + urlCloseRange.length
//        )
//
//        return MarkdownRanges(
//          all: match.fullRange,
//          leading: leadingRange,
//          content: urlRange,
//          trailing: trailingRange
//        )
//
//      default:
//        // For other cases, use a simpler pattern
//        guard let leadingRange = match.capture(at: 1),
//          let contentRange = match.capture(at: 2)
//        else {
//          throw MarkdownRegexError.missingRequiredCapture(index: 2, syntax: syntax)
//        }
//
//        return MarkdownRanges(
//          all: match.fullRange,
//          leading: leadingRange,
//          content: contentRange,
//          trailing: .zero
//        )
//    }
//  }
//
//  private static func highlightCodeBlocks(in backingStore: NSMutableAttributedString) {
//    //    self.beginEditing()
//    guard let regex = Markdown.Syntax.codeBlock.nsRegex else { return }
//    let text = backingStore.string
//    let range = NSRange(location: 0, length: backingStore.length)
//
//    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
//      guard let match = match else { return }
//
//      guard match.range.location + match.range.length <= backingStore.length else { return }
//
//      let fullRange = match.range
//      let codeBlock = (text as NSString).substring(with: fullRange)
//      let lines = codeBlock.components(separatedBy: .newlines)
//
//      let languageHint = lines.first?
//        .replacingOccurrences(of: "```", with: "")
//        .trimmingCharacters(in: .whitespaces)
//
//      backingStore.addAttribute(
//        TextBackground.codeBlock.attributeKey,
//        value: true,
//        range: NSRange(location: 0, length: backingStore.length)
//      )
//
////      backingStore.replaceCharacters(in: fullRange, with: attributedCode)
//
//    }
//    //    self.endEditing()
//  }
//}
