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
    
    let info = self.generateSelectionInfo()
    Task { @MainActor in
      await infoHandler.update(info)
    }
    
    

  }
  //
  //  func selectedTextRange() -> NSTextRange? {
  //    let selectedTextRange = self.textLayoutManager?.textSelections
  //    return selectedTextRange?.first?.textRanges.first
  //  }
  //
  //
  
  //
  //
  //  func getSelectedMarkdownElements() -> [MarkdownElement] {
  //    guard let range = self.selectedTextRange() else { return [] }
  //
  //    return self.markdownBlocks.filter({ $0.range.intersects(range) })
  //
  //  }
  //
  //
  
}

extension EditorInfo.Selection {
  public var summary: String {
    
    let formattedSyntaxNames: String = selectedSyntax.map { syntax in
      syntax.name
    }.joined(separator: ", ")
    
    return """
      Selection: \(selection)
      Selected Syntax: [\(formattedSyntaxNames)]
      Line: \(location?.line.description ?? "nil"), Column: \(location?.column.description ?? "nil")
      """
  }
  
  public static func summaryFor(selection: EditorInfo.Selection) -> String {
    selection.summary
  }
}


extension MarkdownTextView {
  
  func generateSelectionInfo() -> EditorInfo.Selection {
    
    guard let tlm = self.textLayoutManager else { return .init() }
    
    //    let selectedRange = self.selectedRange()
    let selectedRange = self.selectedTextRange()
    
    
    //    guard let selectedLocation = self.selectedTextLocation(),
    //          let textSelections = self.textLayoutManager?.textSelections,
    //          let selectedTextRange = textSelections.first?.textRanges.first,
    //          let selectionDescription: String = textSelections.first?.textRanges.first?.location.description
    //    else { return .init() }
    //
    //    let selectedSyntax = self.getSelectedMarkdownElements().map { block in
    //      block.syntax
    //    }
    //
    //
    //    let currentBlock = self.getMarkdownElement(for: selectedTextRange) ?? .none
    
    let selectedString = tlm.textContentManager?.attributedString(in: selectedRange)
    
    
    //    let fullString = self.string as NSString
    
    //    let tcs = self.textContentStorage
    
    return EditorInfo.Selection(
      selection: (selectedString?.string.count ?? 0).description,
      //      selection: currentBlock?.description ?? "nil",
      selectedSyntax: [],
      location: EditorInfo.Selection.Location(line: 0, column: 0)
      //      lineNumber: self.getLineAndColumn(for: selectedLocation)?.0,
      //      columnNumber: self.getLineAndColumn(for: selectedLocation)?.1
    )
    
  }
  
  
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
  
//  func getSelectedMarkdownElements() -> [MarkdownElement] {
//    guard let tlm = self.textLayoutManager else { return [] }
//    
//    let selection = tlm.textSelections
//    
//    if let firstSelection = selection.first {
//      /// Non-zero selection
//      
//      guard let range = firstSelection.textRanges.first else { return [] }
//      
//      return self.markdownBlocks.filter { $0.range.intersects(range) }
//      
//    } else {
//      /// Zero-length selection
//      
//      return []
//      //      guard let range = firstSelection.textRanges.first else { return [] }
//      
//      //      return self.markdownBlocks.filter { $0.range.contains(<#T##location: any NSTextLocation##any NSTextLocation#>) }
//    }
//    
//  }
  
  
  
  //  func getMarkdownElement(for range: NSTextRange, in blocks: [MarkdownElement]) -> MarkdownElement? {
  //    // First, check if the range intersects with any block
  //    if let intersectingBlock = blocks.first(where: { $0.range.intersects(range) }) {
  //      return intersectingBlock
  //    }
  //
  //    // If not, find the block that contains the range's start location
  //    return blocks.first(where: { $0.range.contains(range.location) })
  //  }
  //
  //  func getSelectedMarkdownElements() -> [MarkdownElement] {
  //    guard let range = self.selectedTextRange() else { return [] }
  //
  //    if range.isEmpty {
  //      // For a single insertion point, return the block containing that point
  //      if let block = getMarkdownElement(for: range, in: self.markdownBlocks) {
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
  //  func getCurrentMarkdownElement(for range: NSTextRange, in blocks: [MarkdownElement]) -> MarkdownElement? {
  //    // First, check if the range is directly within any block
  //    if let directBlock = blocks.first(where: { $0.range.intersects(range) }) {
  //      return directBlock
  //    }
  //
  //    // If not within any block, find the nearest block
  //    var nearestBlock: MarkdownElement?
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
  
  
}
