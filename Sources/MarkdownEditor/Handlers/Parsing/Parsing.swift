//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import BaseHelpers

extension Range where Bound == String.Index {
  func textRange(in string: String, tlm: NSTextLayoutManager) -> NSTextRange {
      
    
    let currentStartLocation: NSTextLocation = self.lowerBound.utf16Offset(in: string)
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
  }
}

extension MarkdownTextView {
  
  func applyMarkdownStyles() async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return }
    
    self.parsingTask?.cancel()
    self.parsingTask = Task {
      
      tcm.performEditingTransaction {
        
        for element in self.elements where element.range.intersects(viewportRange) {
          
          tlm.setRenderingAttributes(element.syntax.contentAttributes, for: element.range)
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
    
    return []
    
  }
  
}

