//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import Foundation
import AppKit
import BaseHelpers
import TextCore


public struct Markdown {
  
  public struct Element: Hashable, Sendable {
    var string: String
    var syntax: Markdown.Syntax
    var range: NSRange
//    var range: Range
    var rect: NSRect?
  }
}

public extension Markdown.Element {
//  struct Range: Hashable {
//    var leading: NSRange
//    var content: NSRange
//    var trailing: NSRange
//  }
  
  mutating func updateRect(
    layoutManager: NSLayoutManager,
    textContainer: NSTextContainer
  ) {
    self.rect = layoutManager.boundingRect(forGlyphRange: self.range, in: textContainer)
  }
  
  var summary: String {
    let result: String = """
    Preview: \(self.string.preview())
    Syntax: \(self.syntax.name)
    Range: \(self.range.info)
    """
    
    return result
  }
}

