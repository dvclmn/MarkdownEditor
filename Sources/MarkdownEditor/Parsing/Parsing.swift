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
import Rearrange
import Wrecktangle

enum SyntaxRangeType {
  case total
  case content
  case leadingSyntax
  case trailingSyntax
}

extension MarkdownTextView {
  
  /// Just realised; for inline Markdown elements, I *should* be safe to only perform
  /// the 'erase-and-re-apply styles' process on a paragraph-by-paragraph basis.
  ///
  /// Because inline elements shouldn't be extending past that anyway.
  ///
  
  
  func parseMarkdownDebounced() {
    
//    DispatchQueue.main.async {
//      for syntax in Markdown.Syntax.testCases {
//        self.parseSyntax(syntax)
//      }
//    }
//    
    
//    guard !isUpdatingFrame || !isUpdatingText else {
//      print("Let's let the operation happen (frame, text), before starting another.")
//      return
//    }
//    
//    self.isUpdatingText = true
//    
//    /// There would be a way to make it work, but currently I think that
//    /// as soon as I style something, I think I'm then taking it away, by resetting
//    /// all the elements in the Set. Need to improve this.
    
              
    
    
              
    
//    
    
  } // END parse and redraw
  
 
  func parseSyntax(_ syntax: Markdown.Syntax) {
    
    //    guard let layoutManager = self.layoutManager else {
    //      fatalError("Issue getting the layout manager")
    //    }
    
    guard let pattern = syntax.regex else {
      print("No regex defined for \(syntax.name)")
      return
    }
    
    var generalInfo: String = "General info\n\n"
    
    guard let textStorage = self.textStorage else {
      fatalError("Issue getting the text storage")
    }

    let string = self.string
    
    generalInfo += string.preview()
    
    guard let nsString = string as NSString? else {
      print("NSString issue")
      return
    }
    
    textStorage.beginEditing()

    var newElements = Set<Markdown.Element>()
    
    var matchesString: String = "Enumeration results:\n"
    var resultCount: Int = 0
    
    
    
    
    
    pattern.enumerateMatches(in: string, range: NSRange(location: 0, length: nsString.length)) { result, flags, stop in
      
      if let result = result {
        
        let elementString: String = textStorage.attributedSubstring(from: result.range).string
        let elementRange: NSRange = result.range

        resultCount += 1
        
        let newInfo: String = "Regex result \(resultCount):\n"
        /// We won't print the `NSTextCheckingResult.CheckingType`, as it's always regularExpression
//        + "\(result.resultType)"
//        + "\n"
        + elementString.preview()
        + result.range.info
        + "\n"
        
        matchesString += newInfo
        
        
//        guard let highlightedCode: NSAttributedString = highlightr.highlight(elementString, as: nil) else {
//          print("Couldn't get the Highlighted string")
//          return
//        }
//        
//        
//        let currentSelection = self.selectedRange
//        
//        textStorage.replaceCharacters(in: elementRange, with: highlightedCode)
//        
//        self.setSelectedRange(currentSelection)
        
        let element = Markdown.Element(
          string: elementString,
          syntax: .codeBlock,
          range: elementRange,
          rect: nil
//          rect: getRect(for: result.range)
        )
        
        newElements.insert(element)
        
        
      } else {
        matchesString += "No result"
      }
    } // END enumerate matches
    
    
    
    
    
    generalInfo += "Total \(syntax.name)s found: \(resultCount)\n\n"
    generalInfo += matchesString
    
    print(Box(header: "Parsing markdown", content: generalInfo))
    
    self.elements = newElements
    
    textStorage.endEditing()
    
  } // END parse code blocks
 
  
} // END extension MD text view

