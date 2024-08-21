//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//

import Foundation
import AppKit

public protocol MarkdownElement: Sendable {
  
  associatedtype MarkdownRegexOutput
  
  var regex: Regex<MarkdownRegexOutput> { get }
  var fullRange: NSTextRange? { get }
  
  /// ```swift
  /// var elements: [AnyMarkdownElement] = [...]
  ///
  ///
  /// // Updating a specific element
  /// if var heading = elements[0] as? Markdown.Heading {
  ///   let updatedHeading = heading.withUpdatedRange(newRange)
  ///   elements[0] = updatedHeading
  /// }
  ///
  /// // Or, if you're iterating through elements
  /// elements = elements.map { element in
  ///   switch element {
  ///     case let heading as Markdown.Heading:
  ///       return heading.withUpdatedRange(newRange) as AnyMarkdownElement
  ///     case let inline as Markdown.InlineSymmetrical:
  ///       return inline.withUpdatedRange(newRange) as AnyMarkdownElement
  ///     default:
  ///       return element
  ///   }
  /// }
  ///
  /// ```
  ///
  func withUpdatedRange(_ newRange: NSTextRange) -> Self
}

extension Markdown {
  
  /// What I've learned so far, defining a very specific per-syntax Regex output type seems
  /// like the best way to simply and accurately define: what is content, and what is syntax?
  ///
  struct Heading: MarkdownElement {
    
    var level: Int
    var regex: Regex<Substring>
    var fullRange: NSTextRange?
    
    func withUpdatedRange(_ newRange: NSTextRange) -> Heading {
      var updated = self
      updated.fullRange = newRange
      return updated
    }
  }
  
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
