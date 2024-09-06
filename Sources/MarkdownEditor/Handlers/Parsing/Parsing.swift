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
//import Rearrange

enum MarkdownSyntax: Equatable {
  
  static var allCases: [MarkdownSyntax] {
    [
      .heading(level: 1),
      .heading(level: 2),
      .heading(level: 3),
      .heading(level: 4),
      .heading(level: 5),
      .heading(level: 6),
      .bold,
      .italic,
      .boldItalic,
      .inlineCode,
      .highlight,
      .strikethrough
    ]
  }
  
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
  
  var shortcut: KeyboardShortcut? {
    switch self {
      case .heading(let level):
        return KeyboardShortcut(key: "\(level)", modifier: .command)
        
      case .bold:
        return KeyboardShortcut(key: "b", modifier: .command)
      case .italic:
        return KeyboardShortcut(key: "i", modifier: .command)
      case .boldItalic:
        return KeyboardShortcut(key: "b", modifier: [.command, .shift])
      case .inlineCode:
        return KeyboardShortcut(key: "`", modifier: nil)
      case .highlight:
        return KeyboardShortcut(key: "h", modifier: .command)
      case .strikethrough:
        return KeyboardShortcut(key: "s", modifier: .command)
    }
  }
  
  static func syntax(for shortcut: KeyboardShortcut) -> MarkdownSyntax? {
    
    let result = MarkdownSyntax.allCases.first { $0.shortcut == shortcut }
    
    print("Got a matching shortcut: \(String(describing: result))")
    
    return result
  }

}


struct KeyboardShortcut: Equatable {
  var key: String
  var modifier: NSEvent.ModifierFlags?
//  var syntax: MarkdownSyntax
  
  init(
    key: String,
    modifier: NSEvent.ModifierFlags? = nil
//    syntax: MarkdownSyntax
  ) {
    self.key = key
    self.modifier = modifier
//    self.syntax = syntax
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
      
      /// This uses the `count` of the leading/trailing syntax characters
      /// provided, to determine that we are 'inside' the syntax content now.
      ///
      let afterOpening = text.index(openingIndex, offsetBy: leadingChars.count)
      
      

      
      /// If this guard is found to be true, then the current loop iteration will end,
      /// but not the whole loop. Execution will continue from the next character
      /// in the text.
      ///
      guard let closingIndex = text[afterOpening...].range(of: trailingChars)?.lowerBound else {
        currentIndex = text.index(after: openingIndex)
        continue
      }
      
      /// If we are here, then the above `guard let closingIndex =`
      /// must have evaluted `true`.
      ///
      

      
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

}

