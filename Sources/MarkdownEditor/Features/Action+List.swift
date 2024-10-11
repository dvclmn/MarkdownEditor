//
//  Action+List.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 11/10/2024.
//

import AppKit
extension MarkdownTextView {

  func handleNewListItem(
    defaultKey: DefaultKeyEvent
  ) {

    print("Let's make a new list item.")

    guard let textStorage else { return }
    
    let paragraphText = self.currentParagraph.string
    let paragraphRange = self.currentParagraph.range
    
    let newListItemPattern = "- "
    let trimmedParagraph = paragraphText.trimmingCharacters(in: .whitespacesAndNewlines)
    print("Trimmed paragraph: \(trimmedParagraph)")
    

    // We're in a list item
    if trimmedParagraph.hasPrefix(newListItemPattern) {
      
      // The *only* contents of this line, is the new list pattern
      if trimmedParagraph == newListItemPattern {
        
        // Pressing return here, should remove the "- ", leaving a clean blank line
        print("If this fires, it should replace the characters with an empty string, because the list item is empty.")
        
        textStorage.replaceCharacters(in: paragraphRange, with: "")
        
        // The list item is empty, so break out of the list
        //        replaceCharacters(in: , with: "\n")
        //        moveSelectedRange(by: 1) // Move cursor to the new line
      } else {
        // Continue the list
        //        print("Trimmed paragraph: `\(trimmedParagraph)` was not equal to `\(newListItemPattern)`")
        let cursorPosition = selectedRange().location
        let textToInsert = "\n- "
        insertText(textToInsert, replacementRange: NSRange(location: cursorPosition, length: 0))
        
        //        moveSelectedRange(by: textToInsert.count) // Move cursor to end of inserted text
      }
      
    } else {
      // Not in a list item, perform default behavior
      defaultKey()
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
