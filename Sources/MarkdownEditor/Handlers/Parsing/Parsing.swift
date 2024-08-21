//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import BaseHelpers

extension Range where Bound == String.Index {
  func textRange(in string: String, provider: NSTextElementProvider) -> NSTextRange? {
      
    let documentLocation: NSTextLocation = provider.documentRange.location
    
    let oldStart: Int = self.lowerBound.utf16Offset(in: string)
    let oldEnd: Int = self.upperBound.utf16Offset(in: string)
    
    guard let newStart = provider.location?(documentLocation, offsetBy: oldStart),
    let newEnd = provider.location?(documentLocation, offsetBy: oldEnd)
    else { return nil }
    
    let finalResult = NSTextRange(location: newStart, end: newEnd)
    
    return finalResult
    
  }
}

extension MarkdownTextView {
  
  func applyMarkdownStyles() async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange,
          let viewportString = tcm.attributedString(in: viewportRange)?.string

    else { return }
    

    
    self.parsingTask?.cancel()
    self.parsingTask = Task {
      
      tcm.performEditingTransaction {
        
        
        for element in self.elements {
          
          guard let textRange = element.range.textRange(in: viewportString, provider: tcm) else { break }
          
          guard textRange.intersects(viewportRange) else { break }
          
          tlm.setRenderingAttributes(element.syntax.contentAttributes, for: textRange)
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
      
      
      for syntax in Markdown.Syntax.testCases {
        
        let newElements: [Markdown.Element] = self.string.markdownMatches(
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
    of syntax: Markdown.Syntax,
    in range: NSTextRange? = nil,
    textContentManager tcm: NSTextContentManager
  ) -> [Markdown.Element] {
    

    printHeader("Let's find markdown elements in a string: \(self.prefix(20))...", value: syntax, diagnostics: .init())
    
    var elements: [Markdown.Element] = []
    
    /// If no range is supplied, we default to the `documentRange`
    ///
    let textRange = range ?? tcm.documentRange
    
    let nsRange = NSRange(textRange, in: tcm)
    
    guard let stringRange = nsRange.range(in: self) else {
      print("Couldn't get `Range<String.Index>` from NSRange")
      return []
    }
    
    print("Got string range: \(stringRange)")
    
    for match in self[stringRange].matches(of: syntax.regex) {
      let contentMatch = match.output.content
      
      let range = match.range
      
      let newElement = Markdown.Element(syntax: syntax, range: match.range)
      
      elements.append(newElement)
      
      print(match.boxedDescription(header: "Hello"))
      
    }
    
    //    var elements: [Markdown.Element] = []
    
    
//    switch element {
//      case let heading as Markdown.Heading:
//        for match in self[stringRange].matches(of: heading.regex) {
//          
//          print(match.prettyDescription)
//          
//          
//          
//          
//        }
//        
//      case let inlineSymmetrical as Markdown.InlineSymmetrical:
//        for match in self[stringRange].matches(of: inlineSymmetrical.regex) {
//          
//          //          let (fullMatch, leadingSyntax, content, trailingSyntax) = match.output
//          
//          print(match.prettyDescription)
//        }
//        
//      default:
//        // Handle unknown types or provide a default behavior
//        print("Unknown MarkdownElement type")
//    }
    
    
    print("Finished this function")
    
    //    print("Here are the elements: \(elements)")
    
    printFooter()
    
    return elements
    
  }
  
}

