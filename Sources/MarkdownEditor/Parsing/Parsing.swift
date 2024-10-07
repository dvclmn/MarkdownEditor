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
          self.highlightElements()
          self.needsDisplay = true
        }
      }
    }
    
    
  } // END parse and redraw
  
  
  func highlightElements() {
    
    guard let textStorage = self.textStorage else {
      print("textStorage issue yeah")
      return
    }
    
    textStorage.beginEditing()
    let currentSelection = selectedRange
    for element in self.elements {
      applyCodeHighlighting(to: element)
    }
    setSelectedRange(currentSelection)
    textStorage.endEditing()
  }
  
  
  func parseCodeBlocks() {
    
    guard let textStorage = self.textStorage else {
      print("Issue getting the text storage")
      return
    }
    
    print("Parsing code blocks")
    print("Current number of elements: \(elements.count)")
    
    let documentText = textStorage.string
    
    //     Temporary set to collect new elements
    var newElements = Set<Markdown.Element>()

    
    guard let pattern = Markdown.Syntax.codeBlock.regex else {
      print("There was an issue with the regex for code blocks")
      return
    }
    
    textStorage.beginEditing()
    
    let matches = documentText.matches(of: pattern)
    
    
    
    for match in matches {
      
      let elementRange = getRange(for: .total, in: match)
      let elementString = getString(for: .content, in: match)
      
      let element = Markdown.Element(
        string: elementString,
        syntax: .codeBlock,
        range: elementRange,
        rect: getRect(for: elementRange)
      )
      
      newElements.insert(element)

    } // END matches
    
    
    textStorage.endEditing()
    
    // Replace the old elements with new ones
    self.elements = newElements
    
  } // END parse code blocks
  
  
  
  func applyCodeHighlighting(to element: Markdown.Element) {
    
    guard let textStorage = self.textStorage else { return }

    guard let highlightedCode: NSAttributedString = highlightr.highlight(element.string, as: "swift") else {
      print("Couldn't get the Highlighted string")
      return
    }
    
    textStorage.replaceCharacters(in: element.range, with: highlightedCode)
  }
  
  
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
    
    guard let string = textStorage?.string as? NSString else {
      print("Couldn't cast to ns string")
      return "nil"
    }
    
    let matchedText: String = string.substring(with: getRange(for: type, in: match))
    
    //    let matchedText = self.attributedSubstring(forProposedRange: getRange(for: .total, in: match), actualRange: nil)
    return matchedText
    
  }
  
  func getRange(for type: SyntaxRangeType, in match: MarkdownRegexMatch) -> NSRange {
    
    let totalRange = NSRange(match.range, in: self.string)
    
    let leadingCount = match.output.leading.count
    let trailingCount = match.output.trailing.count
    
    switch type {
        
      case .total:
        return totalRange
        
      case .content:
        let contentRange = NSRange(location: totalRange.location + leadingCount, length: totalRange.length - (leadingCount + trailingCount))
        return contentRange
        
      case .leadingSyntax:
        let leadingSyntaxRange = NSRange(location: totalRange.location, length: leadingCount)
        return leadingSyntaxRange
        
      case .trailingSyntax:
        let trailingSyntaxRange = NSRange(location: (totalRange.lowerBound - trailingCount), length: trailingCount)
        return trailingSyntaxRange
        
    }
  }
}
