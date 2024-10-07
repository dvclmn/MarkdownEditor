//
//  SelectionChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
//import Wrecktangle

extension MarkdownTextView {
  
  //  public override func setSelectedRange(_ charRange: NSRange) {
  //
  //    super.setSelectedRange(charRange)
  //
  //    updateParagraphInfo(selectedRange: charRange)
  //
  //  }
  
//  public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
//    
//    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)
//    
////    print("Text view frame: `\(self.frame)`")
////    updateParagraphInfo(firstSelected: ranges.first?.rangeValue)
//
//    //    if !stillSelecting {
//    //      printNewSelection()
//    //    }
//  }
  
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
