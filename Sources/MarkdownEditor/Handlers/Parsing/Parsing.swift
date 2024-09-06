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



struct KeyboardShortcut: Equatable {
  var key: String
  var modifier: NSEvent.ModifierFlags?
  
  init(
    key: String,
    modifier: NSEvent.ModifierFlags? = nil
  ) {
    self.key = key
    self.modifier = modifier
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
  
//  func findSyntaxRanges(
//    for syntax: Markdown.Syntax,
//    in scopeRange: NSTextRange
//  ) -> [NSTextRange] {
//    var ranges: [NSTextRange] = []
//    var currentIndex = text.startIndex
//    
//    let leadingChars = syntax.leadingCharacters
//    let trailingChars = syntax.trailingCharacters
//    
//    while currentIndex < text.endIndex {
//      
//      guard let openingIndex = text[currentIndex...].range(of: leadingChars)?.lowerBound else { break } // No more opening delimiters found
//      
//      /// This uses the `count` of the leading/trailing syntax characters
//      /// provided, to determine that we are 'inside' the syntax content now.
//      ///
//      let afterOpening = text.index(openingIndex, offsetBy: leadingChars.count)
//      
//      
//
//      
//      /// If this guard is found to be true, then the current loop iteration will end,
//      /// but not the whole loop. Execution will continue from the next character
//      /// in the text.
//      ///
//      guard let closingIndex = text[afterOpening...].range(of: trailingChars)?.lowerBound else {
//        currentIndex = text.index(after: openingIndex)
//        continue
//      }
//      
//      /// If we are here, then the above `guard let closingIndex =`
//      /// must have evaluted `true`.
//      ///
//      
//
//      
//      let startOffset = text.distance(from: text.startIndex, to: openingIndex)
//      let endOffset = text.distance(from: text.startIndex, to: closingIndex) + trailingChars.count
//      let nsRange = NSRange(location: startOffset, length: endOffset - startOffset)
//      
//      if let textRange = NSTextRange(
//        nsRange,
//        scopeRange: scopeRange,
//        provider: provider
//      ) {
//        ranges.append(textRange)
//      }
//      currentIndex = text.index(closingIndex, offsetBy: trailingChars.count)
//      
//    }
//    
//    return ranges
//  }
  
  
  
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

