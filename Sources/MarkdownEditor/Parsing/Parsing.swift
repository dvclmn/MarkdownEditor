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
    Task {
      await parseDebouncer.processTask {
        
        Task { @MainActor in
          self.basicInlineMarkdown()
          self.needsDisplay = true
        }
      }
    }
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
  

  func parseCodeBlocks() {
    guard let textStorage = self.textStorage else { return }

    let text = textStorage.string
    
    // Temporary set to collect new elements
    var newElements = Set<Markdown.Element>()
    
    // Find matches using regex
//    let matches = codeBlockRegex.matches(in: text, options: [], range: fullRange)
    
    guard let pattern = Markdown.Syntax.codeBlock.regex else {
      print("There was an issue with the regex for code blocks")
      return
    }
    
    let matches = text.matches(of: pattern)
    
    for match in matches {
      
      let element = Markdown.Element(syntax: .codeBlock, range: getRange(for: .total, in: match))
      newElements.insert(element)
    }
    
    // Replace the old elements with new ones
    self.elements = newElements
  }
  
  
  func basicInlineMarkdown() {
    
    guard !configuration.isNeonEnabled, !textIsEditing else { return }
    
    guard let ts = self.textStorage,
          !text.isEmpty
    else {
      print("Text layout manager setup failed")
      return
    }
    
    
    textIsEditing = true
    
    ts.beginEditing()
    
    DispatchQueue.main.async { [weak self] in
      
      guard let self = self else { return }
      
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
      
      
//      for syntax in Markdown.Syntax.testCases {
//        
//        
//                
//      } // END loop syntaxes

      
    } // END dispatch
    
    ts.endEditing()
    
    textIsEditing = false
    
  } // END basicInlineMarkdown
  
  
}
