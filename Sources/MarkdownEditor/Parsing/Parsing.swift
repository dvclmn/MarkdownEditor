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
import Wrecktangle

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
        
        /// I learned that `Task { @MainActor in` is `async`,
        /// whereas `await MainActor.run {` is synchronous.
        ///
        //        await MainActor.run {
        Task { @MainActor in
          self.parseCodeBlocks()
          
          self.styleElement()
          
          self.needsDisplay = true
        }
      }
    }
    
    
  } // END parse and redraw
  
 
  func parseCodeBlocks() {
    
    //    guard let layoutManager = self.layoutManager else {
    //      fatalError("Issue getting the layout manager")
    //    }
    
    guard let textStorage = self.textStorage else {
      fatalError("Issue getting the text storage")
    }
    
    print("Parsing code blocks")
    print("Current number of elements: \(elements.count)")
    
    //    let documentText = textStorage.string
    
    //    guard let documentNSString = self.string as NSString? else {
    //      print("Error getting NSString")
    //      return
    //    }
    
    
    
    
    //     Temporary set to collect new elements
    var newElements = Set<Markdown.Element>()
    
    var matchesString: String = ""
    var resultCount: Int = 0
    
    guard let pattern = Markdown.Syntax.codeBlock.regex else {
      print("There was an issue with the regex for code blocks")
      return
    }
    
    textStorage.beginEditing()
    
    pattern.enumerateMatches(in: self.string, range: NSRange(location: 0, length: self.string.count)) { result, flags, stop in
      
      if let result = result {
        
        resultCount += 1
        
        let newInfo: String = "Regex results (\(resultCount) in total)\n"
        + "\(result.resultType)"
        + "\n"
        + result.range.info
        + "\n"
        
        matchesString += newInfo
        
        
        
        let element = Markdown.Element(
          string: textStorage.attributedSubstring(from: result.range).string,
          syntax: .codeBlock,
          range: result.range,
          rect: getRect(for: result.range)
        )
        
        newElements.insert(element)
        
        
      } else {
        matchesString += "No result"
      }
    } // END enumerate matches
    
    print(Box(header: "Enumeration results", content: matchesString))
    
    
    
    //    let matches = self.string.matches(of: pattern)
    //
    //    //    highlightr.setTheme(to: "xcode-dark")
    //
    //    for match in matches {
    //
    //      let totalString: String = getString(for: .total, in: match)
    //      let totalNSString = totalString as NSString
    //
    //      let attrString = attributedString()
    ////      let lmAttrString = layoutManager.attributedString()
    //
    //      let totalRange = documentNSString.range(of: totalString)
    //      let documentRange = documentNSString.range(of: self.string)
    //
    //      let codeBlockPreview: String = "\n---\n\(totalString.preview(18))\n---\n"
    //
    //      guard let highlightedCode: NSAttributedString = highlightr.highlight(totalString, as: nil) else {
    //                print("Couldn't get the Highlighted string")
    //                return
    //              }
    //
    //
    //      var foregroundAttributes: String = ""
    //
    //      highlightedCode.enumerateAttribute(.foregroundColor, in: documentRange) { attribute, range, stop in
    //        if let attribute = attribute as? NSColor {
    //          foregroundAttributes += attribute.accessibilityName
    //        }
    //      }
    //
    //      let debugString = """
    //      Text preview: \(codeBlockPreview)
    //
    //      `String` Full document char. count: \(self.string.count)
    //      `NSString` Full document range: \(documentNSString.length)
    //      Full document range: \(documentRange.info)
    //
    //      `String` Total match char. count: \(totalString.count)
    //      `NSString` Total match char. count: \(totalNSString.length)
    //      Total match NSRange: \(totalRange.info)
    //
    //      Foreground attributes: \\(foregroundAttributes)
    //
    //      Attr string length: \(attrString.length)
    //      LM's attr string length: \\(lmAttrString.length)
    //
    //      """
    //
    //      print(Box(header: "Debugging Code Blocks", content: debugString))
    //
    
    //
    ////      let attrString: NSAttributedString = attributedString()
    //
    //      if let codeColours = highlightedCode.attribute(.foregroundColor, at: totalRange.location, effectiveRange: nil) {
    //        textStorage.addAttributes([.foregroundColor: codeColours], range: totalRange)
    //      }
    
    
    
    
    
    //      let attributeInfo: String = highlightedCode.debugDescription
    //      print(Box(header: "Attribute info", content: attributeInfo))
    
    
    
    self.elements = newElements
    
    textStorage.endEditing()
    
    
    
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
    
    //    let outputString = "This is the result of `getString`:\n\(substring)"
    //    print(Box(content: outputString))
    return String(substring)
    
    
  }
  
  
}
