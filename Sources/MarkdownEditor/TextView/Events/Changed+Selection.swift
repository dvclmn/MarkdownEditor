//
//  SelectionChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  
  public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
    
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)

//    if !stillSelecting {
//      printNewSelection()
//    }
  }

  func printNewSelection() {
    
    /// I don't need to see anything below a character count of 2
    ///
    guard self.selectedRange().length > 2,
    lastSelectedText != self.selectedText
    else { return }
    
    let result: String = """
    Selected text: \(selectedText)
    """
    
    self.lastSelectedText = selectedText
    
    print(result)
    
  }
  
}
