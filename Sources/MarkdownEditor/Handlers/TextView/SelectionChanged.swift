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
    
    let selectionInfo = calculateSelectionInfo()
    onSelectionChange(selectionInfo)

  }
//  
//  func selectedTextRange() -> NSTextRange? {
//    let selectedTextRange = self.textLayoutManager?.textSelections
//    return selectedTextRange?.first?.textRanges.first
//  }
//  
//  
//  func getMarkdownBlock(for range: NSTextRange, in blocks: [MarkdownBlock]) -> MarkdownBlock? {
//    guard let currentBlock = blocks.first(where: { $0.range.intersects(range) }) else { return nil }
//    return currentBlock
//  }
//  
//  
//  func getSelectedMarkdownBlocks() -> [MarkdownBlock] {
//    guard let range = self.selectedTextRange() else { return [] }
//    
//    return self.markdownBlocks.filter({ $0.range.intersects(range) })
//
//  }
//  
//  
  
  
  
  func selectedTextRange() -> NSTextRange? {
    guard let textSelections = self.textLayoutManager?.textSelections else { return nil }
    
    guard let firstRange = textSelections.first?.textRanges.first else { return nil }
    
    return firstRange
  }
  
  
  func selectedTextLocation() -> NSTextLocation? {
    guard let tlm = self.textLayoutManager,
          let selection = tlm.textSelections.first
    else { return nil }
    
    let resolvedLocation = tlm.textSelectionNavigation.resolvedInsertionLocation(for: selection, writingDirection: .leftToRight)
    
    return resolvedLocation
    
  }
  
  func getSelectedMarkdownBlocks() -> [MarkdownBlock] {
    guard let tlm = self.textLayoutManager else { return [] }
    
    let selection = tlm.textSelections
    
    if let firstSelection = selection.first {
      /// Non-zero selection
      
      guard let range = firstSelection.textRanges.first else { return [] }
      
      return self.markdownBlocks.filter { $0.range.intersects(range) }
      
    } else {
      /// Zero-length selection
      
      guard let range = firstSelection.textRanges.first else { return [] }
      
      return self.markdownBlocks.filter { $0.range.contains(<#T##location: any NSTextLocation##any NSTextLocation#>) }
    }
    
  }
  
  
//  func getMarkdownBlock(for range: NSTextRange, in blocks: [MarkdownBlock]) -> MarkdownBlock? {
//    // First, check if the range intersects with any block
//    if let intersectingBlock = blocks.first(where: { $0.range.intersects(range) }) {
//      return intersectingBlock
//    }
//    
//    // If not, find the block that contains the range's start location
//    return blocks.first(where: { $0.range.contains(range.location) })
//  }
//  
//  func getSelectedMarkdownBlocks() -> [MarkdownBlock] {
//    guard let range = self.selectedTextRange() else { return [] }
//    
//    if range.isEmpty {
//      // For a single insertion point, return the block containing that point
//      if let block = getMarkdownBlock(for: range, in: self.markdownBlocks) {
//        return [block]
//      }
//    } else {
//      // For a non-empty selection, return all intersecting blocks
//      return self.markdownBlocks.filter { $0.range.intersects(range) }
//    }
//    
//    return []
//  }

  
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
    
//    let selectedRange = self.selectedRange()
    let selectedRange = self.selectedTextRange()
    

    let selectedSyntax = self.getSelectedMarkdownBlocks().map { block in
      block.syntax
    }
    
    let fullString = self.string as NSString
    
    let tcs = self.textContentStorage
    

    
    let substring = fullString.substring(to: selectedRange.location)
    let lineNumber = substring.components(separatedBy: .newlines).count
    
    let lineRange = fullString.lineRange(for: NSRange(location: selectedRange.location, length: 0))
    let lineStart = lineRange.location
    let columnNumber = selectedRange.location - lineStart + 1
    
    return EditorInfo.Selection(
      selectedRange: selectedRange,
      selectedSyntax: selectedSyntax,
      lineNumber: lineNumber,
      columnNumber: columnNumber
    )
  }
  
  
}
