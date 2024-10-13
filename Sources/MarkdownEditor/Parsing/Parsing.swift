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

  func parseAllMarkdown() {
    
    var newElements: [Markdown.Element] = []
    
    for syntax in Markdown.Syntax.allCases {
//    for case let syntax in Markdown.Syntax.allCases where syntax.type == .inline  {
      let newElementsForSyntax = parseSingleSyntax(syntax)
      newElements.append(contentsOf: newElementsForSyntax)
    }
    
    self.elements = newElements
  }
  
//  func updateElements(ofType syntax: Markdown.Syntax, with newElements: [Markdown.Element]) {
//    // Remove existing elements of the specified syntax
//    elements = elements.filter { $0.syntax != syntax }
//    
//    // Add the new elements
//   elements.formUnion(newElements)
//    elements.append(contentsOf: newElements)
//  }
  
  
  func parseSingleSyntax(_ syntax: Markdown.Syntax) -> [Markdown.Element] {
    
//    print("Parsing text for instances of \(syntax.name).")
//    if !syntax.regexOptions.isEmpty {
//      print("Note: \(syntax.name) `nsRegex` has options: \(syntax.regexOptions).")
//    }
    
    guard let nsRegex = syntax.nsRegex else {
//      print("Don't need to perform a parse for \(syntax.name), no regex found.")
      return []
    }
    
    
//    var generalInfo: String = "General info\n\n"
    
    //      let rangeOfRenderedText: NSTextRange = tlm.textLayoutFragment(for: CGPointZero)!.rangeInElement
    
    var newElements: [Markdown.Element] = []

    tcm.performEditingTransaction {
      
//      var matchesString: String = "Match results:\n"
      var resultCount: Int = 0
      
      let matches: [NSTextCheckingResult] = nsRegex.matches(in: self.string, range: documentNSRange)
      
      for match in matches {
        
        
        guard let elementString: String = self.string(for: match.range) else {
          print("Error getting the string, for this match? Range: \(match.range)")
          continue
        }
        
        let elementRangeTotal: NSRange = match.range(at: 0)
        let elementRangeLeading: NSRange = match.range(at: 1)
        let elementRangeContent: NSRange = match.range(at: 2)
        let elementRangeTrailing: NSRange = match.range(at: 3)
        
        guard let elementRect: NSRect = self.boundingRect(for: elementRangeTotal) else {
          print("Error getting the NSRect, for this match, with range: \(elementRangeTotal)")
          continue
        }
        
        resultCount += 1
        
//        let newInfo: String = "Regex result \(resultCount):\n"
//        
//        /// We won't print the `NSTextCheckingResult.CheckingType`, as it's always regularExpression
//        + elementString.preview()
//        + match.range.info
//        + "\n"
//        
//        matchesString += newInfo
        
        
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
        
        let ranges = Markdown.Ranges(
          all: elementRangeTotal,
          leading: elementRangeLeading,
          content: elementRangeContent,
          trailing: elementRangeTrailing
        )
        
        let element = Markdown.Element(
          string: elementString,
          syntax: syntax,
          ranges: ranges,
          originY:  elementRect.origin.y,
          rectHeight: elementRect.height
        )
        
//        print("Let's check this element: \(element.summary)")
        
        newElements.append(element)
        

#if DEBUG
        textStorage?.addAttribute(.underlineColor, value: NSColor.red.withAlphaComponent(0.6), range: elementRangeTotal)
        textStorage?.addAttribute(.underlineStyle, value: NSNumber(value: 2), range: elementRangeTotal)
#endif
        
        
        
      } // END match loop
      
//      generalInfo += "Total \(syntax.name)s found: \(resultCount)\n\n"
//      generalInfo += matchesString
//
//      print(Box(header: "Parsing markdown", content: generalInfo))
      
//      print("Found \(resultCount) instances of \(syntax.name).")
      
      
      
    } // END perform edit
    
    return newElements
    
    
  } // END parse code blocks
  
  
} // END extension MD text view

