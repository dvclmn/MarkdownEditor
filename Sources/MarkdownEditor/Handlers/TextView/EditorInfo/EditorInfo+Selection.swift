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
      Line: \(location?.line.description ?? "nil"), Column: \(location?.column.description ?? "nil")
      """
  }
  
  public static func summaryFor(selection: EditorInfo.Selection) -> String {
    selection.summary
  }
}


extension MarkdownTextView {
  
  func updateSelectionInfo() {
    
    guard let tlm = self.textLayoutManager else { return }
    
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
    
    let result = EditorInfo.Selection(
      selection: (selectedString?.string.count ?? 0).description,
      //      selection: currentBlock?.description ?? "nil",
            selectedSyntax: [],
      location: EditorInfo.Selection.Location(line: 0, column: 0)
      //      lineNumber: self.getLineAndColumn(for: selectedLocation)?.0,
      //      columnNumber: self.getLineAndColumn(for: selectedLocation)?.1
    )
    
    self.editorInfo.selection = result
  }
  
  
}

