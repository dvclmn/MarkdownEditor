//
//  Action+KeyDown.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 5/9/2024.
//

//import AppKit
//import BaseHelpers
//

//enum KeyboardKeyCode: UInt16 {
//  case returnKey = 36
//}
//
//extension MarkdownTextView {
//  
//  typealias PassthroughKeyEvent = () -> Void
//  
//  public override func keyDown(with event: NSEvent) {
//    
//    if configuration.isEditable {
//      handleKeyPress(event)
//    } else {
//      super.keyDown(with: event)
//    }
//  } // END key down override
//  
////#warning("Needs keyboard shortcut handling to be improved/implemented")
//  func handleKeyPress(_ event: NSEvent) {
//    /// `charactersIgnoringModifiers` returns an optional, so we unwrap it here
//    guard let pressedKey = event.charactersIgnoringModifiers, pressedKey.count == 1 else {
//      print("Key `\(event.keyCode)` not needed for this operation.")
//      return super.keyDown(with: event)
//    }
//    
//    /// Create shortcuts, on-the-fly, for every key press
//    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
//    let pressedShortcut = KBShortcut(.character(Character(pressedKey)), modifierFlags: modifierFlags)
//    
//    // MARK: - Handle registered shortcuts
//    /// This is where we determine if the above `pressedShortcut`
//    /// is 'registered' or used by an action somewhere else in the code.
//    if let matchingSyntax = Markdown.Syntax.findMatchingSyntax(for: pressedShortcut) {
//      
//      print("---\nPressed shortcut: \(pressedShortcut)\n---\n\n")
//      
//      let hasSelection: Bool = self.selectedRange().length > 0
//      
//      guard hasSelection else {
//        print("Zero-length selection not yet supported for keyboard shortcuts.")
//        return super.keyDown(with: event)
//      }
//      
//      handleWrapping(for: matchingSyntax)
//    }
//    /// There are also other useful key events, that aren't `KBShortcut`s,
//    /// that can trigger actions
//    else if event.keyCode == 36 {
//      
////      handleNewLine {
//        super.keyDown(with: event)
////      }
//      print("Pressed return")
//      
//      
//    }
//    /// We've now exhausted all usefulness checks. If we haven't used this key by now,
//    /// for a shortcut, then we pass it through to the system, as any normal key press.
//    else {
//      super.keyDown(with: event)
//    }
//  }
//
//  enum WrapAction {
//    case wrap
//    case unwrap
//  }
//  
//  func handleWrapping(
//    _ action: WrapAction = .wrap,
//    for syntax: Markdown.Syntax
//  ) {
//    
//    /// 1. Check for characters, and character counts (e.g. 2x asterisks for bold `**`)
//    /// 2. Wrapping:
//    ///   - Create new string from syntax characters and selected content
//    ///   - Adjust range to compensate for new glyphs, keeping original text selected
//    /// 1. Make sure the text selection makes sense?
//    /// 2. Add the right characters (and number of them) around the selection
//    /// 3. Ensure the selection is adjusted
//    
//    let selectedRange = self.selectedRange()
//    
//    guard selectedRange.length > 0 else {
//      print("Zero-length selection not yet supported for syntax wrapping.")
//      return
//    }
//    
//    guard let leadingCharacter = syntax.leadingCharacter,
//          let trailingCharacter = syntax.trailingCharacter,
//          let leadingCount = syntax.leadingCharacterCount,
//          let trailingCount = syntax.trailingCharacterCount
//    else {
//      print("Something failed above")
//      return
//    }
//    
//    
//    let leadingString = String(repeating: leadingCharacter, count: leadingCount)
//    let trailingString = String(repeating: trailingCharacter, count: trailingCount)
//    
//    print("""
//    Let's \(action) selection '\(self.selectedText)', with \(syntax.name) syntax:  '\(leadingString)' and '\(trailingString)'
//    """)
//    
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager
//    else {
//      print("One of the above didn't happen")
//      return
//    }
//    
//    let selectionToReplace: NSRange
//    let selectionAdjustment: NSRange
//    let newText: String
//    
//    
//    switch action {
//      case .wrap:
//        selectionToReplace = selectedRange
//        let newLocation: Int = (selectedRange.location + leadingCount)
//        selectionAdjustment = NSRange(location: newLocation, length: selectedRange.length)
//        newText = leadingString + self.selectedText + trailingString
//        
//      case .unwrap:
//        
//        
//        let newLocation: Int = (selectedRange.location - leadingCount)
//        let newLength: Int = selectedRange.length + (leadingCount + trailingCount)
//        selectionToReplace = NSRange(location: newLocation, length: newLength)
//        
//        selectionAdjustment = NSRange(location: selectedRange.location - leadingCount, length: selectedRange.length)
//        //        selectionAdjustment = NSRange(location: selectedRange.location, length: selectedRange.length)
//        
//        newText = self.selectedText
//        
//    }
//    
//    
//    tcm.performEditingTransaction {
//      
//      
//      self.insertText(newText, replacementRange: selectionToReplace)
//      self.setSelectedRange(selectionAdjustment)
//      
//    } // END perform edit
//    
//    
//    
//  }
//  
  //  func undoWrapping() {
  //    guard let action = undoRedoManager.undo(),
  //          let tlm = self.textLayoutManager,
  //          let tcm = tlm.textContentManager
  //    else {
  //      print("Failed to get undo action or text managers")
  //      return
  //    }
  //
  //    tcm.performEditingTransaction {
  //      // Revert to the old state
  //      self.textStorage?.replaceCharacters(in: action.newRange, with: action.oldText)
  //      self.setSelectedRange(action.oldRange)
  //
  //      // Set up redo
  //      self.undoManager?.registerUndo(withTarget: self) { targetSelf in
  //        targetSelf.redoWrapping()
  //      }
  //
  //      needsDisplay = true
  //      tlm.ensureLayout(for: tlm.documentRange)
  //    }
  //  }
  //
  //  func redoWrapping() {
  //    guard let action = undoRedoManager.redo(),
  //          let tlm = self.textLayoutManager,
  //          let tcm = tlm.textContentManager
  //    else {
  //      print("Failed to get redo action or text managers")
  //      return
  //    }
  //
  //    tcm.performEditingTransaction {
  //      // Apply the wrapped/unwrapped state
  //      self.textStorage?.replaceCharacters(in: action.oldRange, with: action.newText)
  //      self.setSelectedRange(action.newRange)
  //
  //      // Set up undo
  //      self.undoManager?.registerUndo(withTarget: self) { targetSelf in
  //        targetSelf.undoWrapping()
  //      }
  //
  //      needsDisplay = true
  //      tlm.ensureLayout(for: tlm.documentRange)
  //    }
  //  }
  //

//  func handleNewLine(
//    passthroughKey: PassthroughKeyEvent
//  ) {
//    
//    
//    /// This function is called when a new line is created (via return key)
//    /// For now it only checks for list items
//    
//    func trimmedForReference(_ paragraph: String) -> String {
//      paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//    
//    /// This is the paragraph we just left, the one we were on before pressing Return
//    let lineDepartedText = self.paragraphHandler.previousParagraph.string
//    let lineDepartedTrimmed = trimmedForReference(lineDepartedText)
//    let rangeDeparted = self.paragraphHandler.previousParagraph.range
//    
//    /// This is the paragraph we've now landed on, after pressing Return
//    let lineArrivedText = self.paragraphHandler.currentParagraph.string
//    let lineArrivedTrimmed = trimmedForReference(lineArrivedText)
//    //    let rangeArrived = self.paragraphHandler.currentParagraph.range
//    
//    //    print("""
//    //    Trimmed for reference:
//    //      Departed paragraph: \(lineDepartedTrimmed)
//    //      Arrived paragraph: \(lineArrivedTrimmed)
//    //    """)
//    
//    let newListItemPattern = "- "
//    
//    /// Let's check if we're in a list. If not, we pass the key press on through
//    guard let textStorage else {
//      passthroughKey()
//      return
//    }
//    
//    let departedLineIsList: Bool = lineDepartedTrimmed.hasPrefix(newListItemPattern)
//    
//    /// It's occured to me that the 'arrived' line will be a bit of a different case,
//    /// as it'll be the result of whatever I brought with me when pressing Return (if anything)
//    let arrivedLineIsList: Bool = lineArrivedTrimmed.hasPrefix(newListItemPattern)
//    let bothLinesAreList: Bool = departedLineIsList && arrivedLineIsList
//    
//    
//    if departedLineIsList {
//      
//      /// If the paragraph's contents doesn't exactly match the list pattern `- `,
//      /// that means were in a list item with some content. Further down, after this,
//      /// we handle the case where there's no content (empty list item)
//      ///
//      if lineDepartedTrimmed != newListItemPattern {
//        
//        let cursorPosition = selectedRange().location
//        let textToInsert = "\n- "
//        
//        self.insertText(
//          textToInsert,
//          replacementRange: NSRange(location: cursorPosition, length: 0)
//        )
//        
//      }
//      /// The *only* contents of this line, is the new list pattern.
//      /// Pressing return here, should remove the "- ", leaving a clean blank line
//      else {
//        
//        print("If this fires, it should replace the characters with an empty string, because the list item is empty.")
//        
//        textStorage.replaceCharacters(in: rangeDeparted, with: "")
//        
//        // The list item is empty, so break out of the list
//        //        replaceCharacters(in: , with: "\n")
//        //        moveSelectedRange(by: 1) // Move cursor to the new line
//      }
//      
//      
//      
//      
//      
//    } else if arrivedLineIsList {
//      passthroughKey()
//      
//      
//    } else if bothLinesAreList {
//      passthroughKey()
//    } else {
//      passthroughKey()
//    }
//    
//    
//    
//    
//    
//    
//    //    if paragraphText.hasPrefix(newListItemPattern) {
//    //
//    //      if paragraphText == newListItemPattern {
//    //
//    //        replaceCharacters(in: paragraphRange, with: "\n")
//    ////        insertText("\n", replacementRange: self.selectedRange())
//    //      } else {
//    //        insertText("\n- ", replacementRange: self.selectedRange())
//    //      }
//    //
//    //    } else {
//    //      defaultKey()
//    //    }
//    
//  }
  
//}
