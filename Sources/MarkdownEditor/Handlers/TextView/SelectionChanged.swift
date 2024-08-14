//
//  SelectionChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  private func calculateSelectionInfo() -> EditorInfo.Selection {
    let selectedRange = self.selectedRange()
    let fullString = self.string as NSString
    let substring = fullString.substring(to: selectedRange.location)
    let lineNumber = substring.components(separatedBy: .newlines).count
    
    let lineRange = fullString.lineRange(for: NSRange(location: selectedRange.location, length: 0))
    let lineStart = lineRange.location
    let columnNumber = selectedRange.location - lineStart + 1
    
    //    let selectedText = fullString.substring(with: selectedRange)
    
    return EditorInfo.Selection(
      selectedRange: selectedRange,
      lineNumber: lineNumber,
      columnNumber: columnNumber
    )
  }
  
  public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)
    
    if ranges != lastSelectionValue {
      lastSelectionValue = ranges
      let selectionInfo = calculateSelectionInfo()
      onSelectionChange(selectionInfo)
    }
  }
  
}
