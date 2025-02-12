//
//  Cache.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/2/2025.
//

import AppKit
import MarkdownModels
import Highlightr

final class MarkdownCache: Sendable {
  static let shared = MarkdownCache()
  private var cache = NSCache<NSString, NSAttributedString>()
  private var processingQueue = DispatchQueue(label: "com.banksia.markdown.processing", qos: .userInitiated)
  
  func cachedText(for key: String, process: @escaping (String) -> NSAttributedString) async -> NSAttributedString {
    if let cached = cache.object(forKey: key as NSString) {
      return cached
    }
    
    return await withCheckedContinuation { continuation in
      processingQueue.async {
        let processed = process(key)
        self.cache.setObject(processed, forKey: key as NSString)
        continuation.resume(returning: processed)
      }
    }
  }
  
  func invalidate(for key: String) {
    cache.removeObject(forKey: key as NSString)
  }
}


struct ProcessedMarkdown {
  let attributedString: NSAttributedString
  let timestamp: Date
  
  static func process(
    text: String,
    configuration: EditorConfiguration,
    highlightr: Highlightr
//    codeStorage: CodeAttributedString
  ) -> ProcessedMarkdown {
    let store = NSMutableAttributedString(string: text)
    
    // Apply default attributes
    let range = NSRange(location: 0, length: store.length)
    store.setAttributes(configuration.defaultTypingAttributes, range: range)
    
    // Apply markdown styles
    for syntax in Markdown.Syntax.allCases {
      // Your existing styling logic here
      applySyntaxStyle(to: store, syntax: syntax, configuration: configuration)
    }
    
    // Apply code highlighting
    highlightCodeBlocks(in: store, using: highlightr)
    
    return ProcessedMarkdown(
      attributedString: store,
      timestamp: Date()
    )
  }
  
  private static func applySyntaxStyle(
    to backingStore: NSMutableAttributedString,
    syntax: Markdown.Syntax,
    configuration: EditorConfiguration
  ) {
    guard let pattern = syntax.nsRegex else { return }
    let text = backingStore.string
    
    processRegexMatches(
      in: backingStore,
      for: syntax,
      using: pattern
    ) { ranges in
      /// Apply leading syntax attributes
      backingStore.addAttributes(
        syntax.syntaxAttributes(with: configuration).attributes,
        range: ranges.leading
      )
      
      /// Apply content attributes
      backingStore.addAttributes(
        syntax.contentAttributes(with: configuration).attributes,
        range: ranges.content
      )
      
      /// Apply closing syntax attributes
      backingStore.addAttributes(
        syntax.syntaxAttributes(with: configuration).attributes,
        range: ranges.trailing
      )
    }
  }
  
  private static func processRegexMatches(
    in backingStore: NSMutableAttributedString,
    for syntax: Markdown.Syntax,
    using pattern: NSRegularExpression,
    applyAttributes: (MarkdownRanges) -> Void
  ) {
    let text = backingStore.string
    let range = NSRange(location: 0, length: backingStore.length)
    
    pattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
      guard let match = match else { return }
      
      /// Ensure the match range is valid
      guard match.range.location + match.range.length <= backingStore.length else {
        print("Invalid range: \(match.range) for string length: \(backingStore.length)")
        return
      }
      switch syntax {
        case .bold, .italic, .boldItalic, .strikethrough, .inlineCode, .highlight:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          let trailingRange = match.range(at: 3)
          
          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: trailingRange
          )
          applyAttributes(ranges)
          
          
        case .heading, .quoteBlock:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          
          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: .zero
          )
          applyAttributes(ranges)
          
          
        case .list:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          
          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: .zero
          )
          applyAttributes(ranges)
          
          
        case .link, .image:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          let urlRange = match.range(at: 4)
          
          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: urlRange
          )
          applyAttributes(ranges)
          
          
        case .codeBlock:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          let trailingRange = match.range(at: 3)
          
          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: trailingRange
          )
          applyAttributes(ranges)
          
        default:
          break
      }
    }
  }
  
  
  private static func highlightCodeBlocks(
    in backingStore: NSMutableAttributedString,
    using highlightr: Highlightr
  ) {
//    self.beginEditing()
    guard let regex = Markdown.Syntax.codeBlock.nsRegex else { return }
    let text = backingStore.string
    let range = NSRange(location: 0, length: backingStore.length)
    
    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
      guard let match = match else { return }
      
      guard match.range.location + match.range.length <= backingStore.length else { return }
      
      let fullRange = match.range
      let codeBlock = (text as NSString).substring(with: fullRange)
      let lines = codeBlock.components(separatedBy: .newlines)
      
      let languageHint = lines.first?
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespaces)
      
      guard let highlightedCode = highlightr.highlight(codeBlock, as: languageHint ?? "txt") else {
        return
      }
//      guard let highlightr = highlightr,
//      else {
//        return
//      }
      
      let attributedCode = NSMutableAttributedString(attributedString: highlightedCode)
      attributedCode.addAttribute(
        TextBackground.codeBlock.attributeKey,
        value: true,
        range: NSRange(location: 0, length: attributedCode.length)
      )
      
      backingStore.replaceCharacters(in: fullRange, with: attributedCode)
      
    }
//    self.endEditing()
  }
}
