//
//  File.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI



extension EditorInfo.Selection {
  public var summary: String {
    
    let formattedSyntaxNames: String = selectedSyntax.map { syntax in
      syntax.name
    }.joined(separator: ", ")
    
    return """
      Selection: \(selection)
      Selected Syntax: [\(formattedSyntaxNames)]
      Line: \(lineNumber?.description ?? "nil"), Column: \(columnNumber?.description ?? "nil")
      """
  }
  
  public static func summaryFor(selection: EditorInfo.Selection) -> String {
    selection.summary
  }
}


extension MarkdownTextView {
  
  func calculateSelectionInfo() -> EditorInfo.Selection {
    
    guard let tlm = self.textLayoutManager else { return .init() }
    
    //    let selectedRange = self.selectedRange()
    let selectedRange = self.selectedTextRange()
    
    
    //    guard let selectedLocation = self.selectedTextLocation(),
    //          let textSelections = self.textLayoutManager?.textSelections,
    //          let selectedTextRange = textSelections.first?.textRanges.first,
    //          let selectionDescription: String = textSelections.first?.textRanges.first?.location.description
    //    else { return .init() }
    //
    //    let selectedSyntax = self.getSelectedMarkdownBlocks().map { block in
    //      block.syntax
    //    }
    //
    //
    //    let currentBlock = self.getMarkdownBlock(for: selectedTextRange) ?? .none
    
    let selectedString = tlm.textContentManager?.attributedString(in: selectedRange)
    
    
    //    let fullString = self.string as NSString
    
    //    let tcs = self.textContentStorage
    
    return EditorInfo.Selection(
      selection: (selectedString?.string.count ?? 0).description,
      //      selection: currentBlock?.description ?? "nil",
      //      selectedSyntax: selectedSyntax,
      lineNumber: 0,
      //      lineNumber: self.getLineAndColumn(for: selectedLocation)?.0,
      columnNumber: 0
      //      columnNumber: self.getLineAndColumn(for: selectedLocation)?.1
    )
  }
  
  
}

