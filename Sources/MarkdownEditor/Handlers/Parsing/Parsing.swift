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
  
  /// Content/Storage Attributes
  /// These are the attributes that are part of the NSAttributedString stored in the
  /// NSTextStorage (which is accessible through NSTextContentStorage.textStorage)
  /// `textContentStorage.textStorage?.attributes(at: location, effectiveRange: nil)`
  ///
  /// Rendering Attributes
  /// Temporary. Applied using NSTextLayoutManager and affect how text is displayed
  /// without changing the underlying content.
  /// `textLayoutManager.renderingAttributes(at: location)`
  ///
  /// Typing Attributes
  /// These are the default attributes that will be applied to newly typed text.
  /// `textContentStorage.textStorage?.typingAttributes`
  ///
  
  func applyMarkdownStyles() async {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage,
          let viewportRange = tlm.textViewportLayoutController.viewportRange,
          let viewportString = tcm.attributedString(in: viewportRange)?.string

    else { return }
    
    /// Whilst this is 'only' the viewport range, we can/should squeeze out more
    /// performance here, by only affecting the range absolutely neccesary, right
    /// where the user is making edits.
    ///
    let nsViewportRange = NSRange(viewportRange, in: tcm)
    
    
    self.parsingTask?.cancel()
    self.parsingTask = Task {
      
      tcm.performEditingTransaction {
        

        let removableRenderingAttributes: [Attributes.Key] = [
          .foregroundColor,
          .backgroundColor
        ]

        /// I need to verify whether I treat certain attributes differently, based
        /// on whether they are rendering vs
        for attribute in removableRenderingAttributes {
          tlm.removeRenderingAttribute(attribute, for: viewportRange)
        }
        
        
        /// This (`tcs.textStorage?.removeAttribute`) is great —
        /// this does verifyably remove all specified attributes, for the
        /// specified range (`NSRange`).
        ///
        tcs.textStorage?.removeAttribute(.font, range: nsViewportRange)


        /// What am I trying to do?
        /// 1. The app starts, text is there, should be styled via a first pass
        /// 2. I think the code should know what markdown syntax the user's
        /// insertion point is in right now
        
        
        /// `element` here is type `Markdown.Element`
        ///
        /// We are looping through all elements found by the `parseMarkdown` function.
        ///
        for element in self.elements {
          
          guard let markdownNSTextRange = element.markdownNSTextRange(
            element.range,
            in: viewportString,
            syntax: element.syntax,
            provider: tcm
          ) else { break }
          
          guard markdownNSTextRange.content.intersects(viewportRange) else { break }
                
          let contentNSRange = NSRange(markdownNSTextRange.content, in: tcm)
          
//          print("Text range, for rendering attributes: \(markdownNSTextRange.content)")
          
//          tcs.textStorage?.invalidateAttributes(in: contentNSRange)
          
//          tcs.textStorage?.removeAttribute(.font, range: contentNSRange)
          
          guard let attributes = self.configuration.attributes.getAttributes() else { break }
          
          tcs.textStorage?.addAttributes(attributes, range: contentNSRange)
          
          tcs.textStorage?.addAttributes(element.syntax.contentAttributes, range: contentNSRange)
          
          
//          tlm.setRenderingAttributes(element.syntax.contentAttributes, for: markdownNSTextRange.content)
//          tlm.setRenderingAttributes(element.syntax.syntaxAttributes, for: markdownNSTextRange.leading)
//          tlm.setRenderingAttributes(element.syntax.syntaxAttributes, for: markdownNSTextRange.trailing)
          
//          tcm.attributedString(in: markdownNSTextRange.content).attr
          
          
          
          
        }
      } // END perform editing
    } // END task
  }
  
  /// Ideally, this can/should be used both for parsing the *whole* document (used sparingly),
  /// and for parsing smaller portions, based on where the user is editing.
  ///
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
    /// Because of our typealias ``MarkdownRegex``, we can also write it like this:
    /// `Regex<MarkdownRegex.RegexOutput>.Match`.
    ///
    /// So, still overwhelming-looking, but slightly less verbose.
    ///
    for match in self[stringRange].matches(of: syntax.regex) {
      
      /// Get whole match, as `Range<String.Index>`
      let overallRange = match.range
      
      /// `output` is of type `MarkdownRegex.RegexOutput`
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

