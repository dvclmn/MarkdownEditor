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
  
  
  
  /// Ideally, this can/should be used both for parsing the *whole* document (used sparingly),
  /// and for parsing smaller portions, based on where the user is editing.
  ///
  
  func parseAndStyleMarkdownLite(
    in range: NSTextRange? = nil
  ) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange,
          let visibleString = self.visibleString
    else { return }
    
    let parseRange = range ?? viewportRange
    
    let nsRange = NSRange(parseRange, in: tcm)
    
    guard let stringRange = nsRange.range(in: visibleString) else { return }
    
    /// This removes all elements within the visible range.
    ///
    //    for element in self.elements {
    //      if element.range.content.overlaps(stringRange) {
    //        self.elements.removeAll(where: { $0.range == element.range })
    //      }
    //    }
    
    let elementCountBefore: Int = self.elements.count
    var matchDescription: String = ""
    
    
      
      tcm.performEditingTransaction {
        
        /// For testing, I will start with a clean slate, but this feels wasteful and should be changed
        ///
        
        self.elements.removeAll()
        
        /// We need to loop over the syntax that we want to be on the lookout for
        ///
        for syntax in Markdown.Syntax.testCases {
          
          for match in self.string[stringRange].matches(of: syntax.regex) {
            
            matchDescription += match.briefDescription
            
            
            
            //            let markdownRange: MarkdownNSTextRange = self.getMarkdownStringRange(in: match)
            
            guard let markdownRange: MarkdownNSTextRange = self.getMarkdownNSTextRange(in: match) else { break }
            
            let newElement = Markdown.Element(syntax: syntax, range: markdownRange)
            
            self.elements.append(newElement)
            
            self.applyRenderingStyles(to: newElement)
            
            
          } // END match loop
          
        } // END syntax loop
        
        let elementCountAfter: Int = self.elements.count
        
        let metrics: String = """
      
      ---
      \(matchDescription)
      Element count Before: \(elementCountBefore), After: \(elementCountAfter)
      ---
      """
        
//        print(metrics)
        
      } // END performEditingTransaction
      
    
    
    
  } // parseAndStyleMarkdownLite
  
  //  func parseMarkdown(
  //    in range: NSTextRange? = nil
  //  ) async {
  //
  //    guard let tlm = self.textLayoutManager,
  //          let tcm = tlm.textContentManager
  //    else { return }
  //
  //    let searchRange = range ?? tlm.documentRange
  //
  //    self.parsingTask?.cancel()
  //
  //    self.parsingTask = Task {
  //
  //      // TODO: This could be made to be much more efficient I'm sure, by not deleting everything wholesale each time
  //      self.elements.removeAll()
  //      //      self.rangeIndex.removeAll()
  //
  //      for syntax in Markdown.Syntax.testCases {
  //
  //        let newElements: [Markdown.Element] = markdownMatches(
  //          in: self.string,
  //          of: syntax,
  //          range: searchRange,
  //          textContentManager: tcm
  //        )
  //
  //        self.elements.append(contentsOf: newElements)
  //      }
  //    } // END task
  //
  //    await self.parsingTask?.value
  //
  //  }
  
  //  func markdownMatches(
  //    in string: String,
  //    of syntax: Markdown.Syntax,
  //    range: NSTextRange? = nil,
  //    textContentManager tcm: NSTextContentManager
  //  ) -> [Markdown.Element] {
  //
  //    var elements: [Markdown.Element] = []
  //
  //    /// If no range is supplied, we default to the `documentRange`
  //    ///
  //    let textRange = range ?? tcm.documentRange
  //
  //    /// This uses a custom init from `STTextKitPlus`, to get an
  //    /// `NSRange` from a `NSTextRange`
  //    ///
  //    let nsRange = NSRange(textRange, in: tcm)
  //
  //    /// Gets `stringRange`, of type `Range<String.Index>`
  //    ///
  //    guard let stringRange = nsRange.range(in: string) else {
  //      print("Couldn't get `Range<String.Index>` from NSRange")
  //      return []
  //    }
  //
  //    /// `match` here gives us this rather complex type:
  //    /// `Regex<Regex<(Substring, leading: Substring, content: Substring, trailing: Substring)>.RegexOutput>.Match`
  //    ///
  //    /// Because of our typealias ``MarkdownRegex``, we can also write it like this:
  //    /// `Regex<MarkdownRegex.RegexOutput>.Match`.
  //    ///
  //    /// So, still overwhelming-looking, but slightly less verbose.
  //    ///
  //    for match in string[stringRange].matches(of: syntax.regex) {
  //
  //
  //      let markdownRange: MarkdownRange = getMarkdownStringRange(in: match)
  //
  //      let newElement = Markdown.Element(syntax: syntax, range: markdownRange)
  //
  //      elements.append(newElement)
  //
  //
  //
  //    } // END loop over string matches
  //
  //    return elements
  //
  //  } // END markdownMatches
  
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
  
  
  func getMarkdownStringRange(in match: Regex<MarkdownRegex.RegexOutput>.Match) -> MarkdownRange {
    
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
    
    let markdownRange: MarkdownRange = (
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

