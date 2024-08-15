//
//  SelectionChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import STTextKitPlus

extension MarkdownTextView {
  
  
  public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)
    
    if ranges != lastSelectionValue {
      lastSelectionValue = ranges
      let selectionInfo = calculateSelectionInfo()
      onSelectionChange(selectionInfo)
    }
  }
  
  func selectedTextRange() -> NSTextRange? {
    let selectedTextRange = self.textLayoutManager?.textSelections
    return selectedTextRange?.first?.textRanges.first
  }
  
  
  func getCurrentMarkdownBlock(for range: NSTextRange, in blocks: [MarkdownBlock]) -> MarkdownBlock? {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else { return nil }
    
    // First, check if the range is directly within any block
    if let directBlock = blocks.first(where: { $0.range.intersects(range) }) {
      return directBlock
    } else {
      return nil
    }
    
    // If not within any block, find the nearest block
//    var nearestBlock: MarkdownBlock?
//    var smallestDistance = Int.max
    
//    for block in blocks {
//      // Check if range is before the block
//      let offsetBefore = tcm.offset(from: range.endLocation, to: block.range.location)
//      if offsetBefore > 0 && offsetBefore < smallestDistance {
//        smallestDistance = offsetBefore
//        nearestBlock = block
//      }
//      
//      // Check if range is after the block
//      let offsetAfter = tcm.offset(from: block.range.endLocation, to: range.location)
//      if offsetAfter > 0 && offsetAfter < smallestDistance {
//        smallestDistance = offsetAfter
//        nearestBlock = block
//      }
//    }
    
//    return nearestBlock
  }
  
  //
  //  func getCurrentMarkdownBlock(for range: NSTextRange, in blocks: [MarkdownBlock]) -> MarkdownBlock? {
  //    // First, check if the range is directly within any block
  //    if let directBlock = blocks.first(where: { $0.range.intersects(range) }) {
  //      return directBlock
  //    }
  //
  //    // If not within any block, find the nearest block
  //    var nearestBlock: MarkdownBlock?
  //    var smallestDistance = Int.max
  //
  //    for block in blocks {
  //      // Check if range is before the block
  //      if range.endLocation.compare(block.range.location) == .orderedAscending {
  //        if let distance = range.offset(from: range.endLocation, to: block.range.location) {
  //          if distance < smallestDistance {
  //            smallestDistance = distance
  //            nearestBlock = block
  //          }
  //        }
  //      }
  //      // Check if range is after the block
  //      else if range.location.compare(block.range.endLocation) == .orderedDescending {
  //        if let distance = range.offset(from: block.range.endLocation, to: range.location) {
  //          if distance < smallestDistance {
  //            smallestDistance = distance
  //            nearestBlock = block
  //          }
  //        }
  //      }
  //    }
  //
  //    return nearestBlock
  //  }
  //
  //
  private func calculateSelectionInfo() -> EditorInfo.Selection {
    let selectedRange = self.selectedRange()
    
    
    
//    guard let textLayoutManager = self.textLayoutManager else { return nil }
//    
//    if let selectedRange = textLayoutManager.textSelectionNavigation.selectedTextRange {
//      // Use this selectedRange (it's an NSTextRange)
//      // ...
//    }
    
    var currentSyntaxSelection: MarkdownBlock? = nil
    
    if let range = self.selectedTextRange() {
      currentSyntaxSelection = self.getCurrentMarkdownBlock(for: range, in: self.markdownBlocks)
    }
    
    
    let fullString = self.string as NSString
    let substring = fullString.substring(to: selectedRange.location)
    let lineNumber = substring.components(separatedBy: .newlines).count
    
    let lineRange = fullString.lineRange(for: NSRange(location: selectedRange.location, length: 0))
    let lineStart = lineRange.location
    let columnNumber = selectedRange.location - lineStart + 1
    
    return EditorInfo.Selection(
      selectedRange: selectedRange,
      selectedSyntax: currentSyntaxSelection?.syntax,
      lineNumber: lineNumber,
      columnNumber: columnNumber
    )
  }
  
  
  
}
