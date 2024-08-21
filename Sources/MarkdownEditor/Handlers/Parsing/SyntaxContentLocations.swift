//
//  SyntaxContentLocations.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit
import RegexBuilder



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
