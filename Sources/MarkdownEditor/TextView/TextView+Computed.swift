//
//  TextView+Computed.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/10/2024.
//

import AppKit
import Glyph
import Rearrange

extension MarkdownTextView {
  
  var documentNSRange: NSRange {
    guard let tcm = self.textLayoutManager?.textContentManager else { return .notFound }
    return NSRange(tcm.documentRange, provider: tcm)
  }
  
  
  func string(for range: NSRange) -> String? {
    guard let textStorage = textStorage else { return nil }
    
    // Ensure the range is valid
    let validRange = NSIntersectionRange(range, NSRange(location: 0, length: textStorage.length))
    guard validRange.length > 0 else { return nil }
    
    // Use NSAttributedString's substring(with:) method
    return textStorage.attributedSubstring(from: validRange).string
  }
  
//  
//  func lineInfoForCurrentSelection() -> (range: NSRange, content: String)? {
//    guard let textLayoutManager = self.textLayoutManager,
//          let textContentManager = textLayoutManager.textContentManager,
//          let selectedRange = self.selectedRanges.first?.rangeValue else {
//      return nil
//    }
//    
//    // Get the text element for the selection start
//    let locationElement = textLayoutManager.lineFragmentRange(for: T##CGPoint, inContainerAt: T##any NSTextLocation)
//
//    // Find the paragraph that contains the selection
//    guard let paragraphRange = textLayoutManager.textSegment(for: .paragraph, enclosing: selectedRange.location) else {
//      return nil
//    }
//    
//    // Get the content of the paragraph
//    let paragraphContent = textContentManager.attributedString(in: paragraphRange)?.string ?? ""
//    
//    // Find the line break range within the paragraph
//    let nsString = paragraphContent as NSString
//    let lineRange = nsString.lineRange(for: NSRange(location: 0, length: 0))
//    
//    // Adjust the range to be relative to the entire text content
//    let adjustedRange = NSRange(location: paragraphRange.location + lineRange.location,
//                                length: lineRange.length)
//    
//    return (adjustedRange, nsString.substring(with: lineRange))
//  }
  
  
  
}
