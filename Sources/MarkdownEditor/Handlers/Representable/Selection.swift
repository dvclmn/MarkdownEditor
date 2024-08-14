////
////  Selection.swift
////  MarkdownEditor
////
////  Created by Dave Coleman on 13/8/2024.
////
//
//import SwiftUI
//import STTextKitPlus
//
//extension MarkdownTextView {
//  
//  public func selectedTextRange() -> NSTextRange? {
//    textLayoutManager?.textSelections.last?.textRanges.last
//  }
//  
//  public func setSelectedTextRange(_ textRange: NSTextRange) {
//    setSelectedTextRange(textRange, updateLayout: true)
//  }
//  
//  internal func setSelectedTextRange(_ textRange: NSTextRange, updateLayout: Bool) {
//    
//    guard let textLayoutManager = textLayoutManager,
//          isSelectable,
//          textRange.endLocation <= textLayoutManager.documentRange.endLocation
//    else { return }
//    
//    textLayoutManager.textSelections = [
//      NSTextSelection(range: textRange, affinity: .downstream, granularity: .character)
//    ]
//    
////    updateTypingAttributes(at: textRange.location)
//    
//    if updateLayout {
//      needsLayout = true
//    }
//  }
//  
//  public override func setSelectedRange(_ range: NSRange) {
//    
//    guard let contentManager = textLayoutManager?.textContentManager else { return }
//    
//    guard let textRange = NSTextRange(range, in: contentManager) else {
//      preconditionFailure("Invalid range \(range)")
//    }
//    setSelectedTextRange(textRange)
//  }
//  
//}
//
//
