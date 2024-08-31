//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit
import BaseHelpers
import STTextKitPlus
import TextCore

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
        
        let removableAttributes: [Attributes.Key] = [
          .backgroundColor
        ]

        for attribute in removableAttributes {
          tlm.removeRenderingAttribute(attribute, for: viewportRange)
        }
        
        for element in self.elements {
          
          guard let textRange = element.range.textRange(in: viewportString, provider: tcm),
                textRange.intersects(viewportRange)
          else { break }
          
          print("Text range, for rendering attributes: \(textRange)")
          tlm.setRenderingAttributes(element.syntax.contentAttributes, for: textRange)
          
          
        }
      } // END perform editing
    } // END task
  }
  
  
  func parseMarkdown(
    in range: NSTextRange? = nil
  ) async {
    
//    printHeader("Let's parse markdown", diagnostics: .init())
    
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
    } // END task
    
//    printCollection(elements, keyPaths: [\.range.description, \.syntax.name])
    
    await self.parsingTask?.value
    
//    printFooter("Finished parsing markdown")
  }
}

extension String {
  
  func markdownMatches(
    of syntax: Markdown.Syntax,
    in range: NSTextRange? = nil,
    textContentManager tcm: NSTextContentManager
  ) -> [Markdown.Element] {
    

//    printHeader("Let's find markdown elements in a string: \(self.prefix(20))...", value: syntax, diagnostics: .init())
    
    var elements: [Markdown.Element] = []
    
    /// If no range is supplied, we default to the `documentRange`
    ///
    let textRange = range ?? tcm.documentRange
    
    let nsRange = NSRange(textRange, in: tcm)
    
    guard let stringRange = nsRange.range(in: self) else {
      print("Couldn't get `Range<String.Index>` from NSRange")
      return []
    }
    
    for match in self[stringRange].matches(of: syntax.regex) {
      
      let contentMatch = match.output.content
      
      let range = match.range
      
      let newElement = Markdown.Element(syntax: syntax, range: range)
      
      elements.append(newElement)
      
      let headerInfo: String = """
      Content match: \(String(contentMatch))
      Syntax: \(newElement.syntax.name)
      """
      
//      print(match.boxedDescription(header: headerInfo))
      
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
    
    
//    print("Finished this function")
    
        print("Here are the elements: \(elements)")
    
//    printFooter()
    
    return elements
    
  }
  
}

