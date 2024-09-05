//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import Foundation
import AppKit
import BaseHelpers
import TextCore
import Rearrange

//enum TextScope {
//  case paragraph
//  case fullText
//}
//
//struct ScopedTextRange {
//  let range: Range<String.Index>
//  let scope: TextScope
//  let paragraphIndex: Int?  // Only relevant for paragraph scope
//
//  init(range: Range<String.Index>, scope: TextScope, paragraphIndex: Int? = nil) {
//    self.range = range
//    self.scope = scope
//    self.paragraphIndex = paragraphIndex
//
//    if scope == .paragraph && paragraphIndex == nil {
//      fatalError("Paragraph index must be provided for paragraph scope")
//    }
//  }
//}

//extension ScopedTextRange {
//  func toNSTextRange(in provider: NSTextElementProvider) -> NSTextRange? {
//    let nsRange = NSRange(range, in: provider)
//    return NSTextRange(nsRange, provider: provider)
//  }
//}
//
//class TextScopeConverter {
//  let fullText: String
//  let paragraphs: [String]
//
//  init(fullText: String) {
//    self.fullText = fullText
//    self.paragraphs = fullText.components(separatedBy: .newlines)
//  }
//
//  func convertToFullTextScope(_ range: Range<String.Index>, fromParagraph index: Int) -> ScopedTextRange {
//    let paragraphStartIndex = paragraphs[0..<index].reduce(0) { $0 + $1.count + 1 }  // +1 for newline
//    let fullTextStartIndex = fullText.index(fullText.startIndex, offsetBy: paragraphStartIndex)
//    let fullTextRange = Range(
//      uncheckedBounds: (
//        lower: fullText.index(fullTextStartIndex, offsetBy: range.lowerBound.utf16Offset(in: paragraphs[index])),
//        upper: fullText.index(fullTextStartIndex, offsetBy: range.upperBound.utf16Offset(in: paragraphs[index]))
//      )
//    )
//    return ScopedTextRange(range: fullTextRange, scope: .fullText)
//  }
//
//  func convertToParagraphScope(_ range: Range<String.Index>) -> ScopedTextRange? {
//    guard let paragraphIndex = paragraphs.firstIndex(where: { paragraph in
//      let paragraphRange = fullText.range(of: paragraph)!
//      return paragraphRange.overlaps(range)
//    }) else {
//      return nil
//    }
//
//    let paragraphStartIndex = paragraphs[0..<paragraphIndex].reduce(0) { $0 + $1.count + 1 }  // +1 for newline
//    let fullTextStartIndex = fullText.index(fullText.startIndex, offsetBy: paragraphStartIndex)
//    let paragraphRange = Range(
//      uncheckedBounds: (
//        lower: fullText.index(range.lowerBound, offsetBy: -paragraphStartIndex),
//        upper: fullText.index(range.upperBound, offsetBy: -paragraphStartIndex)
//      )
//    )
//    return ScopedTextRange(range: paragraphRange, scope: .paragraph, paragraphIndex: paragraphIndex)
//  }
//}

//// Extension to MarkdownSyntaxFinder to work with ScopedTextRange
//extension MarkdownSyntaxFinder {
//  func findScopedSyntaxRanges(for syntax: MarkdownSyntax, in scope: TextScope, paragraphIndex: Int? = nil) -> [ScopedTextRange] {
//    let ranges = findSyntaxRanges(for: syntax)
//    return ranges.compactMap { range in
//      switch scope {
//        case .fullText:
//          return ScopedTextRange(range: range, scope: .fullText)
//        case .paragraph:
//          guard let paragraphIndex = paragraphIndex else { return nil }
//          let converter = TextScopeConverter(fullText: text)
//          return converter.convertToParagraphScope(range.range(in: text)!)
//      }
//    }
//  }
//}


enum MarkdownSyntax {
  
  case heading(level: Int)
  case bold
  case italic
  case boldItalic
  
  case inlineCode
  case highlight
  case strikethrough
  
  var leadingCharacters: String {
    switch self {
      case .heading(let level):
        return String(repeating: "#", count: level)
        
      case .bold:
        return "**"
        
      case .italic:
        return "*"
        
      case .boldItalic:
        return "***"
        
      case .inlineCode:
        return "`"
      case .highlight:
        return "=="
      case .strikethrough:
        return "~~"
    }
  }
  
  var trailingCharacters: String {
    switch self {
      case .heading:
        "\n"
      case .bold, .italic, .boldItalic, .inlineCode, .highlight, .strikethrough: self.leadingCharacters
    }
  }
  
}


class MarkdownSyntaxFinder {
  let text: String
  let provider: NSTextElementProvider
  
  init(
    text: String,
    provider: NSTextElementProvider
  ) {
    self.text = text
    self.provider = provider
  }
  
  func findSyntaxRanges(
    for syntax: MarkdownSyntax,
    in scopeRange: NSTextRange
  ) -> [NSTextRange] {
    var ranges: [NSTextRange] = []
    var currentIndex = text.startIndex
    
    let leadingChars = syntax.leadingCharacters
    let trailingChars = syntax.trailingCharacters
    
    while currentIndex < text.endIndex {
      
      
      guard let openingIndex = text[currentIndex...].range(of: leadingChars)?.lowerBound else { break } // No more opening delimiters found
      
      
      let afterOpening = text.index(openingIndex, offsetBy: leadingChars.count)
      
      guard let closingIndex = text[afterOpening...].range(of: trailingChars)?.lowerBound else {
        // No closing delimiter found, move to next character
        currentIndex = text.index(after: openingIndex)
        continue
      }
      
      // Check if the opening delimiter is part of a longer sequence
      //      guard isStandaloneDelimiter(at: openingIndex, for: syntax) else {
      //        currentIndex = afterOpening
      //        continue
      //      }
      
      // Check if the closing delimiter is part of a longer sequence
      //      guard isStandaloneDelimiter(at: closingIndex, for: syntax) else {
      //        currentIndex = text.index(after: openingIndex)
      //        continue
      //      }
      
      
      let startOffset = text.distance(from: text.startIndex, to: openingIndex)
      let endOffset = text.distance(from: text.startIndex, to: closingIndex) + trailingChars.count
      
      
      
      let nsRange = NSRange(location: startOffset, length: endOffset - startOffset)
      
      
      if let textRange = NSTextRange(
        nsRange,
        scopeRange: scopeRange,
        provider: provider
      ) {
        ranges.append(textRange)
      }
      currentIndex = text.index(closingIndex, offsetBy: trailingChars.count)
      
    }
    
    return ranges
  }
  
  
  
}

public extension NSTextRange {
  
  convenience init?(
    _ range: NSRange,
    scopeRange: NSTextRange,
    provider: NSTextElementProvider
  ) {
    let docLocation = scopeRange.location
    
    guard let start = provider.location?(docLocation, offsetBy: range.location) else {
      return nil
    }
    
    guard let end = provider.location?(start, offsetBy: range.length) else {
      return nil
    }
    
    self.init(location: start, end: end)
  }
  
//  convenience init?(_ offset: Int, provider: NSTextElementProvider) {
//    let docLocation = provider.documentRange.location
//    
//    guard let start = provider.location?(docLocation, offsetBy: offset) else {
//      return nil
//    }
//    
//    self.init(location: start)
//  }
}

