//
//  MarkdownEditor.swift
//
//
//  Created by Dave Coleman on 11/08/24
//

import SwiftUI
import Syntax
import Shortcuts


extension MarkdownEditor {
  
  static func getHighlightedText(
    text: String
  ) -> NSMutableAttributedString {
    
    print("Let's get the highlighted text and return it")
    
    let highlightedString = NSMutableAttributedString(string: text)
    let all = NSRange(location: 0, length: text.utf16.count)
    
    highlightedString.addAttribute(.font, value: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize), range: all)
    highlightedString.addAttribute(.foregroundColor, value: NSColor.labelColor, range: all)
    
    /// Defining the order manually here, but should test to make sure that this actually makes a difference
    let orderedSyntax: [MarkdownSyntax] = [
      .boldItalic,
      .boldItalicAlt,
      .bold,
      .boldAlt,
      .italic,
      .italicAlt,
      .inlineCode,
      .h1,
      .h2,
      .h3,
      .codeBlock,
      .quoteBlock
    ]
    
    for syntax in orderedSyntax {
      applyStyles(for: syntax, to: highlightedString, in: all)
    }
    
    return highlightedString
  }
  
  
  private static func applyStyles(
    for syntax: MarkdownSyntax,
    to attributedString: NSMutableAttributedString,
    in range: NSRange
  ) {
    
    print("Let's apply the highlight rules")
    let text = attributedString.string
    
    let regex = syntax.regex
    
    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
      
      guard let matchRange = match?.range else { return }
      
      for (key, value) in syntax.contentAttributes {
        attributedString.addAttribute(key, value: value, range: matchRange)
      }
      
      applySyntaxCharacterAttributes(for: syntax, to: attributedString, in: matchRange)
    }
    
  } // END
  
  
  /// Style syntax characters
  ///
  private static func applySyntaxCharacterAttributes(
    for rule: MarkdownSyntax,
    to attributedString: NSMutableAttributedString,
    in matchRange: NSRange
  ) {
    let syntaxChars = rule.syntaxCharacters
    
    /// Different Markdown syntax has different structure and placement of syntax characters
    ///
    
    let syntaxRange = NSRange(location: matchRange.location, length: syntaxChars.count + 1)
    applySyntaxAttributes(for: rule, to: attributedString, in: syntaxRange)
    
    if syntaxChars.count > 1 {
      let closingStart = matchRange.location + matchRange.length - syntaxChars.count
      let closingRange = NSRange(location: closingStart, length: syntaxChars.count)
      applySyntaxAttributes(for: rule, to: attributedString, in: closingRange)
    }
    
  }
  
  
  private static func applySyntaxAttributes(
    for rule: MarkdownSyntax,
    to attributedString: NSMutableAttributedString,
    in range: NSRange
  ) {
    
    for (key, value) in rule.syntaxAttributes {
      attributedString.addAttribute(key, value: value, range: range)
    }
  }
  
}
