//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import BaseHelpers

extension MarkdownTextView {
  
  func applyMarkdownStyles() async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return }
    
    self.parsingTask?.cancel()
    self.parsingTask = Task {
      
      tcm.performEditingTransaction {
        for element in self.elements where element.fullRange?.intersects(viewportRange) {
          tlm.setRenderingAttributes(element.type.contentAttributes, for: element.range)
        }
      } // END perform editing
    } // END task
  }
  
  
  func parseMarkdown(
    in range: NSTextRange? = nil
  ) async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return }
    
    let searchRange = range ?? tlm.documentRange
    
    self.parsingTask?.cancel()
    
    
    self.parsingTask = Task {
      
      self.elements.removeAll()
      self.rangeIndex.removeAll()
      
      
      for syntax in Markdown.allSyntax {
        
        let newElements = self.string.markdownMatches(
          of: syntax,
          in: searchRange,
          textContentManager: tcm
        )
        
        newElements.forEach { element in
          self.elements.append(element)
        }
      }
      //        self.elements.sort { $0.range.location.compare($1.range.location) == .orderedAscending }
    } // END task
    
    await self.parsingTask?.value
    
  }
  
}

extension String {
  
  func markdownMatches(
    of element: AnyMarkdownElement,
    in range: NSTextRange? = nil,
    textContentManager tcm: NSTextContentManager
  ) -> [AnyMarkdownElement] {
    
    
    printHeader("Let's find markdown elements in a string: \(self.prefix(20))...", value: element, diagnostics: .init())
    
    
    /// If no range is supplied, we default to the `documentRange`
    ///
    let textRange = range ?? tcm.documentRange
    
    let nsRange = NSRange(textRange, in: tcm)
    
    guard let stringRange = nsRange.range(in: self) else {
      print("Couldn't get `Range<String.Index>` from NSRange")
      return []
    }
    
    print("Got string range: \(stringRange)")
    
    //    var elements: [AnyMarkdownElement] = []
    
    
    switch element {
      case let heading as Markdown.Heading:
        for match in self[stringRange].matches(of: heading.regex) {
          
          print(match.prettyDescription)
          
          
          
          
        }
        
      case let inlineSymmetrical as Markdown.InlineSymmetrical:
        for match in self[stringRange].matches(of: inlineSymmetrical.regex) {
          
          //          let (fullMatch, leadingSyntax, content, trailingSyntax) = match.output
          
          print(match.prettyDescription)
        }
        
      default:
        // Handle unknown types or provide a default behavior
        print("Unknown MarkdownElement type")
    }
    
    
    print("Finished this function")
    
    //    print("Here are the elements: \(elements)")
    
    printFooter()
    
    return []
    
  }
  
}

