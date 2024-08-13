//
//  Selection.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import STTextKitPlus

extension MarkdownView {
  
  public func selectedTextRange() -> NSTextRange? {
    textLayoutManager.textSelections.last?.textRanges.last
  }
  
  public func setSelectedTextRange(_ textRange: NSTextRange) {
    setSelectedTextRange(textRange, updateLayout: true)
  }
  
  internal func setSelectedTextRange(_ textRange: NSTextRange, updateLayout: Bool) {
    guard isSelectable, textRange.endLocation <= textLayoutManager.documentRange.endLocation else {
      return
    }
    
    textLayoutManager.textSelections = [
      NSTextSelection(range: textRange, affinity: .downstream, granularity: .character)
    ]
    
    updateTypingAttributes(at: textRange.location)
    
    if updateLayout {
      needsLayout = true
    }
  }
  
  public func setSelectedRange(_ range: NSRange) {
    guard let textRange = NSTextRange(range, in: textContentManager) else {
      preconditionFailure("Invalid range \(range)")
    }
    setSelectedTextRange(textRange)
  }
  
}
