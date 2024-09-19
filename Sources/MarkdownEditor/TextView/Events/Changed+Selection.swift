//
//  SelectionChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import Wrecktangle

extension MarkdownTextView {
  
//  public override func setSelectedRange(_ charRange: NSRange) {
//    
//    super.setSelectedRange(charRange)
//    
//    updateParagraphInfo(selectedRange: charRange)
//    
//  }
  
    public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
  
      super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)
  
      updateParagraphInfo(selectedRange: ranges.first!.rangeValue)
      
  //    if !stillSelecting {
  //      printNewSelection()
  //    }
    }
  
  func updateParagraphInfo(selectedRange: NSRange) {
    
    let nsString = self.string as NSString
    let range = nsString.paragraphRange(for: selectedRange)
    guard let text = self.attributedSubstring(forProposedRange: range, actualRange: nil)?.string else {
      print("Couldn't get that text")
      return
    }
    
    var syntax: BlockSyntax
    

    if text.hasPrefix("#") {
      
      let headingLevel = text.prefix(while: { $0 == "#" }).count
      
      if headingLevel <= 6 && (text.count == headingLevel || text[text.index(text.startIndex, offsetBy: headingLevel)] == " ") {
        syntax = BlockSyntax.heading(level: headingLevel)
      } else {
        syntax = BlockSyntax.heading(level: 1)
      }
      
    } else if text.hasPrefix("- ") {
      syntax = .list
    } else {
      // TODO: Implement more cases
      syntax = .none
    }
    
    let result = ParagraphInfo(string: text, range: range, type: syntax)
    
    
    let box = Box(header: "Paragraph Info", content: result.description)
    
//    print(box)
    
    self.currentParagraph = result
    
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
