//
//  MarkdownEditor.swift
//
//
//  Created by Dave Coleman on 11/08/24
//

import SwiftUI
import Syntax
import Shortcuts

//struct WrappingConfig {
//  let syntax: WrappableSyntax
//  let triggerKey: String?
//  let shortcut: Keyboard.Shortcut?
//  
//  init(syntax: WrappableSyntax, triggerKey: String? = nil, shortcut: Keyboard.Shortcut? = nil) {
//    self.syntax = syntax
//    self.triggerKey = triggerKey
//    self.shortcut = shortcut
//  }
//}


let defaultEditorFont = NSFont.systemFont(ofSize: 15)
let defaultEditorTextColor = NSColor.labelColor


extension MarkdownEditor {
  var placeholderFont: NSColor { NSColor() }
  
  static func getHighlightedText(
    text: String
  ) -> NSMutableAttributedString {
    
    print("Let's get the highlighted text and return it")
    
    let highlightedString = NSMutableAttributedString(string: text)
    let all = NSRange(location: 0, length: text.utf16.count)
    
    highlightedString.addAttribute(.font, value: defaultEditorFont, range: all)
    highlightedString.addAttribute(.foregroundColor, value: defaultEditorTextColor, range: all)
    
    /// Defining the order manually here, but should test to make sure that this actually makes a difference
    let orderedRules: [MarkdownSyntax] = [
      .boldItalic,
      .boldItalicAlt,
      .bold,
      .boldAlt,
      .italic,
      .italicAlt,
      .inlineCode,
      .codeBlock,
      .quoteBlock
    ]
    
    for rule in orderedRules {
      
      applyHighlightRule(rule, to: highlightedString, in: all)
      
    }
    
    return highlightedString
  }
  
  
  private static func applyHighlightRule(
    _ rule: MarkdownSyntax,
    to attributedString: NSMutableAttributedString,
    in range: NSRange
  ) {
    
    print("Let's apply the highlight rules")
    let text = attributedString.string
    
    let regex = rule.regex
    
    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
      
      guard let matchRange = match?.range else { return }
      
      for (key, value) in rule.contentAttributes {
        attributedString.addAttribute(key, value: value, range: matchRange)
      }
      
      applySyntaxCharacterAttributes(for: rule, to: attributedString, in: matchRange)
      

    }
    
  } // END applyHighlightRule
  
  private static func applySyntaxCharacterAttributes(
    for rule: MarkdownSyntax,
    to attributedString: NSMutableAttributedString,
    in matchRange: NSRange
  ) {
    let syntaxChars = rule.syntaxCharacters
    
    let syntaxRange = NSRange(location: matchRange.location, length: syntaxChars.count)
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
