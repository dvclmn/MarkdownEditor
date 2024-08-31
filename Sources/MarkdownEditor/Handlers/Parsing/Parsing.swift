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
          
          guard let markdownNSTextRange = element.nsTextRange(element.range, in: viewportString, syntax: element.syntax, provider: tcm),
                markdownNSTextRange.content.intersects(viewportRange)
                
          else { break }
          
          print("Text range, for rendering attributes: \(markdownNSTextRange.content)")
          
          tlm.setRenderingAttributes(element.syntax.contentAttributes, for: markdownNSTextRange.content)
          tlm.setRenderingAttributes(element.syntax.syntaxAttributes, for: markdownNSTextRange.leading)
          tlm.setRenderingAttributes(element.syntax.syntaxAttributes, for: markdownNSTextRange.trailing)
          
          
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

    var elements: [Markdown.Element] = []
    
    /// If no range is supplied, we default to the `documentRange`
    ///
    let textRange = range ?? tcm.documentRange
    
    /// This uses a custom init from `STTextKitPlus`, to get an
    /// `NSRange` from a `NSTextRange`
    ///
    let nsRange = NSRange(textRange, in: tcm)
    
    /// Gets `stringRange`, of type `Range<String.Index>`
    ///
    guard let stringRange = nsRange.range(in: self) else {
      print("Couldn't get `Range<String.Index>` from NSRange")
      return []
    }
    
    /// `match` here gives us this rather complex type:
    /// `Regex<Regex<(Substring, leading: Substring, content: Substring, trailing: Substring)>.RegexOutput>.Match`
    ///
    for match in self[stringRange].matches(of: syntax.regex) {
      
      let overallRange = match.range
      let output = match.output
      
      // Calculate the ranges for leading, content, and trailing
      let leadingEndIndex = self.index(overallRange.lowerBound, offsetBy: output.leading.count)
      let leadingRange = overallRange.lowerBound..<leadingEndIndex
      
      let contentEndIndex = self.index(leadingEndIndex, offsetBy: output.content.count)
      let contentRange = leadingEndIndex..<contentEndIndex
      
      let trailingRange = contentEndIndex..<overallRange.upperBound

      let markdownRange: MarkdownRange = (
        leading: leadingRange,
        content: contentRange,
        trailing: trailingRange
      )
      
//      let contentMatch = match.output.content
      
//      let range = match.range
      
      // Now you can use this markdownRange to create your Markdown.Element
       let element = Markdown.Element(syntax: syntax, range: markdownRange)
       elements.append(element)

      
      
      print("Match: \(match)")
//      let range: Range<String.Index> = match.range
      
//      let newElement = Markdown.Element(syntax: syntax, range: range)
      
//      elements.append(newElement)
      
      let headerInfo: String = """
      Content match: \\(String(contentMatch))
      Syntax: \\(newElement.syntax.name)
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

