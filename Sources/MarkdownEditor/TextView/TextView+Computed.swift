//
//  TextView+Computed.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/10/2024.
//

import AppKit
import Glyph
import Rearrange
import Foundation

extension MarkdownTextView {
  
  var documentNSRange: NSRange {
    guard let tcm = self.textLayoutManager?.textContentManager else { return .notFound }
    return NSRange(tcm.documentRange, provider: tcm)
  }
  
  var nsString: NSString {
    return self.string as NSString
  }
  
  var documentLength: Int {
    self.nsString.length
  }
  
  var safeCurrentParagraphRange: NSRange {
    let paragraphRange: NSRange = nsString.paragraphRange(for: safeSelectedRange)
    return paragraphRange.clamped(to: documentLength)
  }
  
  var safeSelectedRange: NSRange {
    
    let result: NSRange = selectedRange.clamped(to: documentLength)
    
//    print("Calculated safeSelectedRange: \(result)")
    return result
  }
  
  func getSafeRange(for range: NSRange) -> NSRange {
    return range.clamped(to: documentLength)
  }


  func string(for range: NSRange) -> String? {
    guard let textStorage = textStorage else { return nil }
    
    // Ensure the range is valid
    let validRange = NSIntersectionRange(range, NSRange(location: 0, length: textStorage.length))
    guard validRange.length > 0 else { return nil }
    
    // Use NSAttributedString's substring(with:) method
    return textStorage.attributedSubstring(from: validRange).string
  }
  
  
}
