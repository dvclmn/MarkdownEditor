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
    let lineDepartedText = self.paragraphHandler.previousParagraph.string
    let lineDepartedTrimmed = trimmedForReference(lineDepartedText)
    let rangeDeparted = self.paragraphHandler.previousParagraph.range
        
    /// This is the paragraph we've now landed on, after pressing Return
    let lineArrivedText = self.paragraphHandler.currentParagraph.string
    let lineArrivedTrimmed = trimmedForReference(lineArrivedText)
//    let rangeArrived = self.paragraphHandler.currentParagraph.range
    
//    print("""
//    Trimmed for reference:
//      Departed paragraph: \(lineDepartedTrimmed)
//      Arrived paragraph: \(lineArrivedTrimmed)
//    """)
    
    let newListItemPattern = "- "
    
    /// Let's check if we're in a list. If not, we pass the key press on through
    guard let textStorage else {
      passthroughKey()
      return
    }
    
    let departedLineIsList: Bool = lineDepartedTrimmed.hasPrefix(newListItemPattern)
    
    /// It's occured to me that the 'arrived' line will be a bit of a different case,
    /// as it'll be the result of whatever I brought with me when pressing Return (if anything)
    let arrivedLineIsList: Bool = lineArrivedTrimmed.hasPrefix(newListItemPattern)
    let bothLinesAreList: Bool = departedLineIsList && arrivedLineIsList
    
    
    if departedLineIsList {
      
      /// If the paragraph's contents doesn't exactly match the list pattern `- `,
      /// that means were in a list item with some content. Further down, after this,
      /// we handle the case where there's no content (empty list item)
      ///
      if lineDepartedTrimmed != newListItemPattern {
        
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
        
        textStorage.replaceCharacters(in: rangeDeparted, with: "")
        
        // The list item is empty, so break out of the list
        //        replaceCharacters(in: , with: "\n")
        //        moveSelectedRange(by: 1) // Move cursor to the new line
      }

      
      
      
      
    } else if arrivedLineIsList {
      passthroughKey()
      
      
    } else if bothLinesAreList {
      passthroughKey()
    } else {
      passthroughKey()
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
