//
//  MarkdownEditor.swift
//
//
//  Created by Dave Coleman on 11/08/24
//

import SwiftUI


extension MarkdownEditor {
  
  
  /// Style syntax characters
  ///
  private static func applySyntaxAttributes<S: MarkdownSyntax>(
    for syntax: S,
    to attributedString: NSMutableAttributedString,
    in range: NSRange
  ) {
    
    for (key, value) in syntax.syntaxAttributes {
      attributedString.addAttribute(key, value: value, range: range)
    }
  }
  
//  func setCodeBlockBackgrounds(for textView: MDTextView) {
    
//    let ranges = [NSRange]()
    
    
    
    // Clear previous highlights
//    textView.codeBlockLayer?.highlightRects = []
    
    // Update highlights for each code block
//    for range in ranges {
//      updateCodeBlockHighlight(for: range)
//    }
    
    
//  }
  
  
//  static func getHighlightedText(
//    text: String
//  ) -> NSMutableAttributedString {
//    
//    print("Let's get the highlighted text and return it")
//    
//    let highlightedString = NSMutableAttributedString(string: text)
//    let all = NSRange(location: 0, length: text.utf16.count)
//    
//    highlightedString.addAttribute(.font, value: NSFont.systemFont(ofSize: MarkdownDefaults.fontSize), range: all)
//    highlightedString.addAttribute(.foregroundColor, value: NSColor.labelColor, range: all)
//    
//    /// Defining the order manually here, but should test to make sure that this actually makes a difference
//    let orderedSyntax: [Markdown.Syntax] = [
//      .boldItalic,
//      .boldItalicAlt,
//      .bold,
//      .boldAlt,
//      .italic,
//      .italicAlt,
//      .inlineCode,
//      .h1,
//      .h2,
//      .h3,
//      .codeBlock,
//      .quoteBlock
//    ]
//    
//    for syntax in orderedSyntax {
//      applyStylesToContent(for: syntax, to: highlightedString, in: all)
//    }
//    
//    return highlightedString
//  }
  
  
//  private static func applyStylesToContent(
//    for syntax: Markdown.Syntax,
//    to attributedString: NSMutableAttributedString,
//    in range: NSRange
//  ) {
//    
//    print("Let's apply the highlight syntaxes")
//    let text = attributedString.string
//    
//    let regex = syntax.regex
//    
//    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
//      
//      guard let matchRange = match?.range else { return }
//      
//      for (key, value) in syntax.contentAttributes {
//        attributedString.addAttribute(key, value: value, range: matchRange)
//      }
//      
////      if syntax == .codeBlock {
//        
////              attributedString.addCodeBlockBackground(to: range)
////      }
//      
//      let characters = syntax.syntaxCharacters
//      
//      //    if syntax.isSyntaxSymmetrical {
//      //
//      //    }
//      
//      /// What questions are we asking
//      /// 1. How many syntax characters
//      /// 2. Are they on the left or the right
//      /// 3. Is this a block, line or inline type of syntax
//      
//      /// Process syntax characters on the left
//      ///
//      let syntaxRange = NSRange(location: matchRange.location, length: characters.count + 1)
//      
//      applySyntaxAttributes(for: syntax, to: attributedString, in: syntaxRange)
//      
//      /// Process syntax characters on the right
//      ///
//      if characters.count > 1 {
//        let closingStart = matchRange.location + matchRange.length - characters.count
//        let closingRange = NSRange(location: closingStart, length: characters.count)
//        applySyntaxAttributes(for: syntax, to: attributedString, in: closingRange)
//      }
//    }
//    
//  } // END
  
 
  
//  
//  func addAttributes(
//    for syntax: Markdown.Syntax,
//    to type: SyntaxType
//    to attributedString: NSMutableAttributedString,
//    in range: NSRange
//  ) {
//    
//  }
  
}


