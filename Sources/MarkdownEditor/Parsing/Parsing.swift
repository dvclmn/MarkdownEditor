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
  
  
  func parseAndRedraw() {
    
    /// There would be a way to make it work, but currently I think that
    /// as soon as I style something, I think I'm then taking it away, by resetting
    /// all the elements in the Set. Need to improve this.
    Task {
      await parseDebouncer.processTask {
        
        Task { @MainActor in
          self.parseCodeBlocks()
          self.needsDisplay = true
        }
      }
    }
    
    
  } // END parse and redraw
  
  
  
  func parseCodeBlocks() {
    
    guard let textStorage = self.textStorage else {
      print("Issue getting the text storage")
      return
    }
    
    print("Parsing code blocks")
    print("Current number of elements: \(elements.count)")
    
    let documentText = textStorage.string
    
    guard let documentNSString = textStorage.string as NSString? else {
      print("Error getting NSString")
      return
    }
    
    let currentSelection = selectedRange
    //     Temporary set to collect new elements
    var newElements = Set<Markdown.Element>()
    
    
    guard let pattern = Markdown.Syntax.codeBlock.regex else {
      print("There was an issue with the regex for code blocks")
      return
    }
    
    textStorage.beginEditing()
    
    
    let matches = documentText.matches(of: pattern)
    
    //    highlightr.setTheme(to: "xcode-dark")
    
    for match in matches {
      
      //      let elementRange = getRange(for: .total, in: match)
      //      let elementString = getString(for: .total, in: match)
      
      let totalString = getString(for: .total, in: match)
      let totalRange: NSRange = documentNSString.range(of: totalString)
      
      guard let highlightedCode: NSAttributedString = highlightr.highlight(totalString, as: "swift") else {
        print("Couldn't get the Highlighted string")
        return
      }
      
      //      textStorage.replaceCharacters(in: totalRange, with: highlightedCode)
      
      let element = Markdown.Element(
        string: totalString,
        syntax: .codeBlock,
        range: totalRange,
        rect: getRect(for: totalRange)
      )
      
      newElements.insert(element)
      
    } // END matches
    
    
    textStorage.endEditing()
    
    // Replace the old elements with new ones
    self.elements = newElements
    
    setSelectedRange(currentSelection)
    
  } // END parse code blocks
  
  
  
  
  
} // END extension MD text view




/// Some backup code
///

//      let documentLength = (self.string as NSString).length
//      let paragraphRange = self.currentParagraph.range
//
//      // Ensure the paragraph range is within the document bounds
//      let safeParagraphRange = NSRange(
//        location: min(paragraphRange.location, documentLength),
//        length: min(paragraphRange.length, documentLength - paragraphRange.location)
//      )
//
//      if safeParagraphRange.length > 0 {
//
//        ts.removeAttribute(.foregroundColor, range: safeParagraphRange)
//        ts.removeAttribute(.backgroundColor, range: safeParagraphRange)
//        ts.addAttributes(AttributeSet.white.attributes, range: safeParagraphRange)
//
//      } else {
//        print("Invalid paragraph range")
//      }

//      for element in self.elements {
//        <#body#>
//      }
//
//      ts.addAttributes(syntax.syntaxAttributes(with: self.configuration).attributes, range: syntaxRange)
//      ts.addAttributes(syntax.contentAttributes(with: self.configuration).attributes, range: contentRange)




extension MarkdownTextView {
  
  //  func applyAttributedString(_ attrString: NSAttributedString) {
  
  //          // Apply attributes instead of replacing the text
  //          highlightedCode.enumerateAttributes(in: getRange(for: .total, in: match), options: []) { attrs, range, _ in
  //
  //            let effectiveRange = NSRange(location: codeRange.location + range.location, length: range.length)
  //
  //            textStorage.setAttributes(attrs, range: effectiveRange)
  //          }
  //
  //            textStorage.setAttributes(highlightedCode, range: getRange(for: .content, in: match))
  //
  //
  //
  //            for attribute in highlightedCode {
  //              attribute.
  //            }
  //
  //            textStorage.addAttributes(T##attrs: [NSAttributedString.Key : Any]##[NSAttributedString.Key : Any], range: T##NSRange)
  //
  //            ts.setAttributedString(highlightedCode)
  
  
  //  }
  
  
  
  func getString(for type: SyntaxRangeType, in match: MarkdownRegexMatch) -> String {
    
    let substring: Substring
    
    switch type {
      case .total:
        substring = match.output.0
        
      case .content:
        substring = match.output.content
        
      case .leadingSyntax:
        substring = match.output.leading
        
      case .trailingSyntax:
        substring = match.output.trailing
        
    }
    
    return String(substring)
    
    
  }
  
  
}
