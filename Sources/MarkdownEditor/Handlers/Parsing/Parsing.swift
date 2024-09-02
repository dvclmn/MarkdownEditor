//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import Foundation
import AppKit
import BaseHelpers
import STTextKitPlus
import TextCore


extension MarkdownTextView {
  
  enum ChangeTrigger {
    case text
    case appeared
    case scroll
  }

  func parseAndStyleMarkdownLite(
    in range: NSTextRange? = nil,
    trigger: ChangeTrigger
  ) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return }
    
//    print("\n\n------\nParse and style markdown.")
    
    var parseRange: NSTextRange
    
    switch trigger {
      case .text:
        parseRange = range ?? viewportRange
      case .appeared:
        parseRange = tlm.documentRange
      case .scroll:
        parseRange = range ?? viewportRange
    }
    
    let nsRange = NSRange(parseRange, in: tcm)
    
    // Add safety check
    guard nsRange.location != NSNotFound && nsRange.length != NSNotFound else {
      print("Invalid NSRange: \(nsRange)")
      return
    }

    
    
    tcm.performEditingTransaction {
      
      // Add more detailed logging
      print("String length: \(self.string.count)")
      print("NSRange: \(nsRange)")

//      guard let stringRange = nsRange.range(in: self.string) else {
//        print("Couldn't convert NSRange to String.Index range. NSRange: \(nsRange), String length: \(self.string.count)")
//        return // Instead of fatalError, we return to avoid crashing
//      }
//      
      
      /// IMPORTANT:
      /// I previously had the below set to `nsRange.range(in: self.visibleString)`,
      /// which I believe caused incorrect range calculations. I think it needs to be
      /// provided the whole string, to calculate the correct start/end locations etc.
      ///
//      guard let stringRange = nsRange.range(in: self.string) else {
//        fatalError("Couldn't get string range")
//      }
      
      guard let defaultRenderingAttributes = self.configuration.renderingAttributes.getAttributes()
      else { return }
      
      DispatchQueue.main.async {
        tlm.setRenderingAttributes(defaultRenderingAttributes, for: parseRange)
      }
      
      if trigger == .text {
        self.elements.removeAll()
        
//        self.removeElements(in: parseRange)
        
      }
      
//      self.enumerateTextElements(from: range.location, options: []) { element in
        //
        //      guard let textRange = element.elementRange else { return false }
        //
        //      if textRange.endLocation >= range.endLocation {
        //
        //        print("Returning false. I wonder what is in here? \(element)")
        //
        //        return false
        //      }
        //
        //      print("Otherwise, returning true. \(element)")
        //      return true
        //    }
        //  }
      
      tcm.enumerateTextElements(from: parseRange.location) { element in
        guard let textParagraph = element as? NSTextParagraph,
              let textContent = textParagraph.attributedString.string as String?,
              let textRange = element.elementRange
        
        else { return false }
        
        if textRange.endLocation >= parseRange.endLocation {
          return false
        }
        
        for syntax in Markdown.Syntax.testCases {
          
          guard let regex = syntax.regex else { continue }
          
          let matches = textContent.matches(of: regex)
          
          for match in matches {
            
//            print("Text: \(textContent)")
//            print("Matches: \(match.briefDescription)")
            
            
            
//            if let markdownRange = self.convertToMarkdownNSTextRange(match.range, in: textRange, contentManager: tcm) {
//              let newElement = Markdown.Element(syntax: syntax, range: markdownRange)
//              self.addMarkdownElement(newElement)
//            }
          } // END match loop
        } // END syntax loop
        
        return true
      }
//
//      /// We need to loop over the syntax that we want to be on the lookout for
//      ///
//      /// I think that longer-spanning elements like code blocks, may need their own logic
//      /// for parsing and styling, so they are not inhibited by viewport range issues.
//      ///
//      for syntax in Markdown.Syntax.testCases {
//        
//        guard let regex = syntax.regex else {
////          print("No regex (currently) for this syntax type: \(syntax.name)")
//          continue
//        }
//        
//        for match in self.string[stringRange].matches(of: regex) {
//          
//          //          print("\(match.briefDescription)")
//          
//          guard let markdownRange: MarkdownNSTextRange = self.getMarkdownNSTextRange(in: match)
//          else {
//            print("Error converting ranges to `MarkdownNSTextRange`")
//            break
//          }
//          
//          let newElement = Markdown.Element(syntax: syntax, range: markdownRange)
//          
//          self.addMarkdownElement(newElement)
//          
//        } // END match loop
//        
//      } // END syntax loop
//      
      
      
      //      let codeBlockRegex: Regex<Substring> = /(?m)^```[\s\S]*?^```/
      //
      //      for match in self.string[stringRange].matches(of: codeBlockRegex) {
      //
      //        print("match: \(match.output)")
      //
      //        guard let nsTextRange = getSingleNSTextRange(in: match) else {
      //          print("Couldn't get it!")
      //          break
      //        }
      //
      //        tlm.setRenderingAttributes(Markdown.Syntax.codeBlock.contentRenderingAttributes, for: nsTextRange)
      
      
    } // END performEditingTransaction
    
//    print("Finished parsing and styling\n------\n")
  } // parseAndStyleMarkdownLite
  
  
//  func convertToMarkdownNSTextRange(_ matchRange: Range<String.Index>, in textRange: NSTextRange, contentManager: NSTextContentManager) -> MarkdownNSTextRange? {
//    guard let startOffset = contentManager.offset(from: textRange.location, to: matchRange.lowerBound),
//          let endOffset = contentManager.offset(from: textRange.location, to: matchRange.upperBound)
//    else { return nil }
//    
//    let startLocation = contentManager.location(textRange.location, offsetBy: startOffset)
//    let endLocation = contentManager.location(textRange.location, offsetBy: endOffset)
//    
//    guard let start = startLocation, let end = endLocation else { return nil }
//    
//    return MarkdownNSTextRange(location: start, endLocation: end)
//  }
  
  
  
  func getSingleNSTextRange(
    in match: Regex<Regex<Substring>.RegexOutput>.Match
  ) -> NSTextRange? {
    
    
    /// Get whole match, as `Range<String.Index>`
    let fullRange = match.range
    
    /// `output` is of type `MarkdownRegex.RegexOutput`
    let output = match.output
    
    /// Calculate the indices/ranges for leading, content, and trailing
    ///
    /// Indices in `String.Index` format, ranges as `Range<String.Index>`
    ///
    
    let endIndex = string.index(fullRange.lowerBound, offsetBy: output.count)
    let range = fullRange.lowerBound..<endIndex
    
    guard let nsTextRange = getNSTextRange(from: range, in: self.string) else { return nil }
    
    return nsTextRange
    
    
  }
  
  func getMarkdownNSTextRange(
    in match: Regex<MarkdownRegex.RegexOutput>.Match
  ) -> MarkdownNSTextRange? {
    
    let markdownStringRange = getMarkdownStringRange(in: match)
    
    guard let nsLeadingRange = getNSTextRange(from: markdownStringRange.leading, in: self.string),
          let nsContentRange = getNSTextRange(from: markdownStringRange.content, in: self.string),
          let nsTrailingRange = getNSTextRange(from: markdownStringRange.trailing, in: self.string)
            
    else { return nil }
    
    let markdownNSTextRange: MarkdownNSTextRange = (
      leading: nsLeadingRange,
      content: nsContentRange,
      trailing: nsTrailingRange
    )
    
    return markdownNSTextRange
  }
  
  
  func getMarkdownStringRange(in match: Regex<MarkdownRegex.RegexOutput>.Match) -> MarkdownStringRange {
    
    /// Get whole match, as `Range<String.Index>`
    let fullRange = match.range
    
    /// `output` is of type `MarkdownRegex.RegexOutput`
    let output = match.output
    
    /// Calculate the indices/ranges for leading, content, and trailing
    ///
    /// Indices in `String.Index` format, ranges as `Range<String.Index>`
    ///
    let leadingEndIndex = string.index(fullRange.lowerBound, offsetBy: output.leading.count)
    let leadingRange = fullRange.lowerBound..<leadingEndIndex
    
    let contentEndIndex = string.index(leadingEndIndex, offsetBy: output.content.count)
    let contentRange = leadingEndIndex..<contentEndIndex
    
    let trailingRange = contentEndIndex..<fullRange.upperBound
    
    let markdownRange: MarkdownStringRange = (
      leading: leadingRange,
      content: contentRange,
      trailing: trailingRange
    )
    
    return markdownRange
    
  }
  
  
  func getNSTextRange(from range: Range<String.Index>, in string: String) -> NSTextRange? {
    
    guard let tcm = self.textLayoutManager?.textContentManager,
          let startLocation = tcm.location(at: string.distance(from: string.startIndex, to: range.lowerBound)),
          let endLocation = tcm.location(at: string.distance(from: string.startIndex, to: range.upperBound))
    else { return nil }
    
    return NSTextRange(location: startLocation, end: endLocation)
  }
  
}

