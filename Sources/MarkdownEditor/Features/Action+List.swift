//
//  Action+List.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 11/10/2024.
//

import AppKit
extension MarkdownTextView {
  
  func handleNewLine(
    passthroughKey: PassthroughKeyEvent
  ) {
    
    
    /// This function is called when a new line is created (via return key)
    /// For now it only checks for list items
    
    func trimmedForReference(_ paragraph: String) -> String {
      paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// This is the paragraph we just left, the one we were on before pressing Return
    let paragraphTextDeparted = self.paragraphHandler.previousParagraph.string
    let departedTrimmed = trimmedForReference(paragraphTextDeparted)
    let paragraphRangeDeparted = self.paragraphHandler.previousParagraph.range
        
    /// This is the paragraph we've now landed on, after pressing Return
    let paragraphTextArrived = self.paragraphHandler.currentParagraph.string
    let arrivedTrimmed = trimmedForReference(paragraphTextArrived)
    let paragraphRangeArrived = self.paragraphHandler.currentParagraph.range
    
    
    
    print("""
    Trimmed for reference:
      Departed paragraph: \(trimmedForReference(paragraphTextDeparted))
      Arrived paragraph: \(trimmedForReference(paragraphTextArrived))
    """)
    
    let newListItemPattern = "- "
    
    /// Let's check if we're in a list. If not, we pass the key press on through
    guard let textStorage else {
      passthroughKey()
      return
    }
    
    let departedLineIsList: Bool = departedTrimmed.hasPrefix(newListItemPattern)
    let arrivedLineIsList: Bool = arrivedTrimmed.hasPrefix(newListItemPattern)
    let bothLinesAreList: Bool = departedLineIsList && arrivedLineIsList
    
    
    if departedLineIsList {
      
      /// If the paragraph's contents doesn't exactly match the list pattern `- `,
      /// that means were in a list item with some content. Further down, after this,
      /// we handle the case where there's no content (empty list item)
      ///
      if departedTrimmed != newListItemPattern {
        
        let cursorPosition = selectedRange().location
        let textToInsert = "\n- "
        
        self.insertText(
          textToInsert,
          replacementRange: NSRange(location: cursorPosition, length: 0)
        )
        
      }
      /// The *only* contents of this line, is the new list pattern.
      /// Pressing return here, should remove the "- ", leaving a clean blank line
      else {
        
        print("If this fires, it should replace the characters with an empty string, because the list item is empty.")
        
        textStorage.replaceCharacters(in: paragraphRangeDeparted, with: "")
        
        // The list item is empty, so break out of the list
        //        replaceCharacters(in: , with: "\n")
        //        moveSelectedRange(by: 1) // Move cursor to the new line
      }

      
      
      
      
    } else if arrivedLineIsList {
      
      
      
    } else if bothLinesAreList {
      
    } else {
      
    }
    
    
    
    
    
    
    //    if paragraphText.hasPrefix(newListItemPattern) {
    //
    //      if paragraphText == newListItemPattern {
    //
    //        replaceCharacters(in: paragraphRange, with: "\n")
    ////        insertText("\n", replacementRange: self.selectedRange())
    //      } else {
    //        insertText("\n- ", replacementRange: self.selectedRange())
    //      }
    //
    //    } else {
    //      defaultKey()
    //    }
    
  }
  
}
