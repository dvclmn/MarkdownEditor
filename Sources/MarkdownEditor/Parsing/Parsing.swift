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
    
//    Task {
//      await parsingDebouncer.processTask { [weak self] in
//        for syntax in Markdown.Syntax.testCases {
//          await self?.parseSyntax(syntax)
//        }
//      }
//    }
    
        DispatchQueue.main.async {
          for syntax in Markdown.Syntax.testCases {
            self.parseSyntax(syntax)
          }
        }
    

    
    
    
    //
    
  } // END parse and redraw
  
  
  func parseSyntax(_ syntax: Markdown.Syntax) {
    
    //    guard let regexLiteral = syntax.regexLiteral else {
    //      return
    //    }
    
    guard let nsRegex = syntax.nsRegex else {
      return
    }
    
    
    var generalInfo: String = "General info\n\n"
    
    //      let rangeOfRenderedText: NSTextRange = tlm.textLayoutFragment(for: CGPointZero)!.rangeInElement
    
    
    
    
    var newElements = Set<Markdown.Element>()
    
    
    
    tcm.performEditingTransaction {
      
      
      
      var matchesString: String = "Match results:\n"
      var resultCount: Int = 0
      
      
      
      let matches: [NSTextCheckingResult] = nsRegex.matches(in: self.string, range: documentNSRange)
      
      for match in matches {
        
        let elementString: String = "textStorage.attributedSubstring(from: result.range).string"
        let elementRange: NSRange = match.range
        //        let elementRect: CGRect = self.firstRect(forCharacterRange: elementRange)
        
        
        
        resultCount += 1
        
        let newInfo: String = "Regex result \(resultCount):\n"
        
        /// We won't print the `NSTextCheckingResult.CheckingType`, as it's always regularExpression
        + elementString.preview()
        + match.range.info
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
          //          rect: self.boundingRect(for: elementRange)?.size
          //          rect: getRect(for: result.range)
        )
        
        newElements.insert(element)
        
      } // END match loop
      
      generalInfo += "Total \(syntax.name)s found: \(resultCount)\n\n"
      generalInfo += matchesString
      
      print(Box(header: "Parsing markdown", content: generalInfo))
      
      self.elements = newElements
      
      
    } // END perform edit
    
    
    
  } // END parse code blocks
  
  
} // END extension MD text view

