////
////  Ranges.swift
////  MarkdownEditor
////
////  Created by Dave Coleman on 13/8/2024.
////
//
//import SwiftUI
//
//extension NSTextContentManager {
//  func range(for textRange: NSTextRange) -> NSRange? {
//    let location = offset(from: documentRange.location, to: textRange.location)
//    let length = offset(from: textRange.location, to: textRange.endLocation)
//    if location == NSNotFound || length == NSNotFound { return nil }
//    return NSRange(location: location, length: length)
//  }
//  
//  func textRange(for range: NSRange) -> NSTextRange? {
//    guard let textRangeLocation = location(documentRange.location, offsetBy: range.location),
//          let endLocation = location(textRangeLocation, offsetBy: range.length) else { return nil }
//    return NSTextRange(location: textRangeLocation, end: endLocation)
//  }
//}
//
//extension MarkdownTextView {
//  
//  public func textRange(for rect: NSRect) -> NSRange {
//    let length = self.textStorage?.length ?? 0
//    
//    guard let layoutManager = self.layoutManager else {
//      return NSRange(0..<length)
//    }
//    
//    guard let container = self.textContainer else {
//      return NSRange(0..<length)
//    }
//    
//    let origin = textContainerOrigin
//    let offsetRect = rect.offsetBy(dx: origin.x, dy: origin.y)
//    
//    let glyphRange = layoutManager.glyphRange(forBoundingRect: offsetRect, in: container)
//    
//    return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
//  }
//  
//  var visibleTextRange: NSRange {
//    return textRange(for: visibleRect)
//  }
//
//  /// All the selected ranges, as NSRange instances
//  public var selectedTextRanges: [NSRange] {
//    get {
//      return selectedRanges.map({ $0.rangeValue })
//    }
//    set {
//      selectedRanges = newValue.map { NSValue(range: $0) }
//    }
//  }
//
//  /// A single range representing a single, continuous selection
//  ///
//  /// This method returns nil if there isn't exactly one selection range.
//  public var selectedContinuousRange: NSRange? {
//    let ranges = selectedTextRanges
//    if ranges.count != 1 {
//      return nil
//    }
//    
//    return ranges.first!
//  }
//
//  /// A singlel location representing a single, zero-length selection
//  ///
//  /// This method returns nil if there is more than one selected range,
//  /// or if that range has a non-zero length.
//  public var insertionLocation: Int? {
//    guard let range = selectedContinuousRange else {
//      return nil
//    }
//    
//    return range.length == 0 ? range.location : nil
//    }
//}
