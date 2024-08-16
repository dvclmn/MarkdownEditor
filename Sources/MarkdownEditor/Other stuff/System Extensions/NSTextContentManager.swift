////
////  File.swift
////  MarkdownEditor
////
////  Created by Dave Coleman on 13/8/2024.
////
//
//import SwiftUI
//import STTextKitPlus
//
//
//extension NSTextView {
//  
////  func getLineAndColumnNumber(for range: NSTextRange) -> (line: Int, column: Int)? {
////    
////    
////    
////    let substring = self.string.substring(to: range.location)
////    let lineNumber = substring.components(separatedBy: .newlines).count
////    
////    let lineRange = fullString.lineRange(for: NSRange(location: selectedRange.location, length: 0))
////    let lineStart = lineRange.location
////    let columnNumber = selectedRange.location - lineStart + 1
////    
////    
////  }
//  
//  func getLineAndColumn(for location: NSTextLocation) -> (line: Int, column: Int)? {
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager else {
//      return nil
//    }
//    
////    // Get the line fragment for the given location
////    guard let lineFragment = tlm.textLayoutFragment(for: location) else {
////      return nil
////    }
//    
//    guard let range = NSTextRange(
//      location: tlm.documentRange.location,
//      end: tlm.textViewportLayoutController.viewportRange?.location
//    ) else { return nil }
//    
//    let textElements = tcm.textElements(for: range)
//    
//    return (textElements.count, textElements.count + 2)
////
////    // Calculate line number
////    let lineRange = lineFragment.textLineFragment.rangeInElement
////    let startOfDocument = tcm.documentRange.location
////    let rangeToLine = NSTextRange(location: startOfDocument, end: lineRange.location)
////    let lineNumber = tcm.textLineFragments(for: rangeToLine).count + 1
////    
////    // Calculate column number
////    let columnNumber = textLayoutManager.offset(from: lineRange.location, to: location) + 1
////    
////    return (lineNumber, columnNumber)
//  }
//
//  
//}
