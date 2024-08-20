//
//  SyntaxContentLocations.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit


protocol MarkdownElement: Sendable {
  
  associatedtype MarkdownRegexOutput
  
  var regex: Regex<MarkdownRegexOutput> { get }
  var fullRange: NSTextRange? { get }
  
  func updateRange() -> NSTextRange
}

extension MarkdownElement {
  func updateRange() -> NSTextRange {
    
  }
}

extension Regex<Substring>: @unchecked @retroactive Sendable {
  
}

extension NSTextRange: @unchecked @retroactive Sendable {
  
}

extension Markdown {
  
  /// What I've learned so far, defining a very specific per-syntax Regex output type seems
  /// like the best way to simply and accurately define: what is content, and what is syntax?
  ///
  struct Heading: MarkdownElement {
    
    
    var level: Int
    
    /// The first `Substring` is always the full match. Then the second and third are for syntax and content
    ///
    var regex: Regex<Substring>
    
    
    var fullRange: NSTextRange?
    
    
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
    
//    static let bold = InlineSymmetrical(
//      type: .bold,
//      regex: /\\*\\*.*?\\*\\*/,
//      fullRange: nil
//    )
//    
    static let bold = InlineSymmetrical(
      type: .bold,
      regex: /(\*\*|__)(.+?)(\1)/,
      fullRange: nil
    )
    
  }
  
}




extension Markdown.Element {
  
  /// This is the best/only way (for now) that I can think of to distinguish:
  /// What is markdown *content*, and what is markdown *syntax*, so they can be styled uniquely.
  ///
  /// Currently this is being achieved by using `Regex<Substring>` to obtain a *full range*
  /// capture of the markdown, content + syntax together. I was previously using capture groups
  /// (which as I'm writing this is probably a way better solution).
  func contentRange(in tlm: NSTextLayoutManager) -> NSTextRange? {
    
    let currentStartLocation: NSTextLocation = fullRange.location
    let currentEndLocation: NSTextLocation = fullRange.endLocation
    
    let characterCount = type.syntaxCharacterCount
    
    var newStartLocation: NSTextLocation? = nil
    var newEndLocation: NSTextLocation? = nil
    
    switch type.syntaxBoundary {
      case .enclosed(let enclosedType):
        switch enclosedType {
          case .symmetrical:
            
            /// Push the start point to the right ➡️ by the number of syntax characters
            /// Pull the end point to the left ⬅️ by the number of syntax characters
            ///
            guard let offsetStart = tlm.location(currentStartLocation, offsetBy: characterCount),
                  let offsetEnd = tlm.location(currentEndLocation, offsetBy: -characterCount)
            else { return nil }
            
            newStartLocation = offsetStart
            newEndLocation = offsetEnd
            
            
          case .asymmetrical:
            
            let startOffset: Int = 1
            
            // TODO: I think i'm going to need a new Regex for the inside of links and images?
            
            /// Push the start point by only *one*
            /// Rhis is for links and images, so componesating for the `[` character)
            ///
            guard let offsetStart = tlm.location(currentStartLocation, offsetBy: startOffset)
            else { return nil }
            
            newStartLocation = offsetStart
            newEndLocation = currentEndLocation
            
        }
        
      case .leading:
        guard let offsetStart = tlm.location(currentStartLocation, offsetBy: characterCount)
        else { return nil }
        
        newStartLocation = offsetStart
        
      case .none:
        print("Do nothing, because a horizontal rule is 'all-syntax'")
    }
    
    
    guard let start = newStartLocation,
          let end = newEndLocation,
          let newRange = NSTextRange(location: start, end: end)
    else { return nil }
    
    return newRange
  } // END content range
}
