//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//

import Foundation
import AppKit

//public typealias Markdown.Element = (any MarkdownElement)


public protocol MarkdownElement: Sendable {
  associatedtype MarkdownRegexOutput
  var regex: Regex<MarkdownRegexOutput> { get }
}

public protocol MarkdownHeading {
  
  var level: Int { get }
}

extension Markdown {
  
  struct Element {
    var syntax: Markdown.Syntax
    var range: MarkdownRange
  }
  
  /// What I've learned so far, defining a very specific per-syntax Regex output type seems
  /// like the best way to simply and accurately define: what is content, and what is syntax?
  ///
//  struct Heading: MarkdownHeading {
//    
//    var level: Int
//    var regex: Regex<Substring>
//    
//    func withUpdatedRange(_ newRange: NSTextRange) -> Heading {
//      var updated = self
//      updated.fullRange = newRange
//      return updated
//    }
//  }
  
  struct InlineSymmetrical: MarkdownElement {
    
    var type: SyntaxType
    
    /// Substring definitions:
    ///
    /// 1. Full match
    /// 2. Leading syntax
    /// 3. Content
    /// 4. Trailing syntax
    ///
    var regex: Regex<(Substring, Substring, Substring, Substring)>
    
    var fullRange: NSTextRange?
    
    enum SyntaxType {
      case bold, italic, boldItalic, strikethrough, highlight, inlineCode
    }
    
    func withUpdatedRange(_ newRange: NSTextRange) -> InlineSymmetrical {
      var updated = self
      updated.fullRange = newRange
      return updated
    }
  }
}
