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
//import Wrecktangle

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
    
//    guard let regexPattern = syntax.regex else {
//      print("No regex defined for \(syntax.name)")
//      return
//    }
    
    guard let pattern = syntax.regexLiteral else {
      return
    }
    
    guard let tlm = textLayoutManager,
          let tcm = tlm.textContentManager
    else {
      return
    }
    
    var generalInfo: String = "General info\n\n"
    
//    guard let textStorage = self.textStorage else {
//      fatalError("Issue getting the text storage")
//    }

//    let string: String = self.string
    
//    generalInfo += string.preview()
    
//    guard let nsString = string as NSString? else {
//      print("NSString issue")
//      return
//    }
    
//    tcm.performEditingTransaction {
      
      
      
      //    textStorage.beginEditing()
      
      var newElements = Set<Markdown.Element>()
      
      var matchesString: String = "Enumeration results:\n"
      var resultCount: Int = 0
      
    
    
    
    
//      let shrimb = try NSRegularExpression(pattern: pattern)
     
//      shrimb.enumerateMatches(in: "Hello", range: NSRange(location: 0, length: 500)) { match, _, _ in
        
        
          
          let elementString: String = "textStorage.attributedSubstring(from: result.range).string"
          let elementRange: NSRange = match.range
          let elementRect: CGRect = self.firstRect(forCharacterRange: elementRange)
          
          
          
          resultCount += 1
          
          let newInfo: String = "Regex result \(resultCount):\n"
          /// We won't print the `NSTextCheckingResult.CheckingType`, as it's always regularExpression
          //        + "\(result.resultType)"
          //        + "\n"
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
            rect: self.boundingRect(for: elementRange)?.size
            //          rect: getRect(for: result.range)
          )
          
          newElements.insert(element)

          
      } // END enumerate matches
      
      
      
      
    } catch {
      print("No luck with the regex")
    }
    
      
      
      
      
      generalInfo += "Total \(syntax.name)s found: \(resultCount)\n\n"
      generalInfo += matchesString
      
//      print(Box(header: "Parsing markdown", content: generalInfo))
      
      self.elements = newElements
      
//    } // END perform edit
    
//    textStorage.endEditing()
    
  } // END parse code blocks
 
  
} // END extension MD text view

