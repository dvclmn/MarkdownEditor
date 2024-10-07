//
//  Action+KeyDown.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 5/9/2024.
//

import AppKit
import Rearrange
import Shortcuts

extension MarkdownTextView {
  
  typealias DefaultKeyEvent = () -> Void
  
  public override func keyDown(with event: NSEvent) {
    
    guard let pressedKey = event.charactersIgnoringModifiers, pressedKey.count == 1 else {
      print("Key `\(event.keyCode)` not needed for this operation.")
      return super.keyDown(with: event)
    }
    
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let pressedShortcut = Keyboard.Shortcut(.character(Character(pressedKey)), modifierFlags: modifierFlags)
    
    if let matchingSyntax = Markdown.Syntax.findMatchingSyntax(for: pressedShortcut) {
      
      let hasSelection: Bool = self.selectedRange().length > 0
      guard hasSelection else {
        print("Zero-length selection not yet supported for keyboard shortcuts.")
        return super.keyDown(with: event)
      }
      
      handleWrapping(for: matchingSyntax)
    } else if pressedKey == "\n" || event.keyCode == 36 {
      
//      handleNewListItem {
        super.keyDown(with: event)
//      }
      
//      print("Pressed return")
    
  } else {
//      print("Shortcut didn't match any syntax shortcuts, handing the event back to the system.")
      super.keyDown(with: event)
    }
    
  } // END key down override
  
  
//  func currentLineContents() -> String? {
//    guard let textStorage = textStorage else { return nil }
//    let string = textStorage.string
//    let selectedRange = self.selectedRange()
//    
//    // Find the start of the current line
//    
//    
//
//    
//    // Find the end of the current line
//    let lineEnd = (string as NSString).lineRange(for: selectedRange).upperBound
//    
//    // Extract the contents of the current line
//    let currentLine = (string as NSString).substring(with: NSRange(location: lineStart, length: lineEnd - lineStart))
//    
//    return currentLine
//  }
  
  
  
  func handleNewListItem(
    defaultKey: DefaultKeyEvent
  ) {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else {
      print("One of the above didn't happen")
      return
    }
    
    let nsString = self.string as NSString
    let paragraphRange = nsString.paragraphRange(for: self.selectedRange())
    guard let paragraphText = self.attributedSubstring(forProposedRange: paragraphRange, actualRange: nil)?.string else {
      defaultKey()
      return
    }
    
//    print("Paragraph: \(paragraphText)")
    
//    let paragraphStartPattern: Regex<(Substring, listContent: Substring)> = /^ -(?<listContent>.*?)/
    let newListItemPattern = "- "
    let trimmedParagraph = paragraphText.trimmingCharacters(in: .whitespacesAndNewlines)
    
    
    
    if trimmedParagraph.hasPrefix(newListItemPattern) {
      // We're in a list item
      if trimmedParagraph == newListItemPattern {
        
        print(paragraphRange)
        
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
  
  
  
  enum WrapAction {
    case wrap
    case unwrap
  }

  func handleWrapping(
    _ action: WrapAction = .wrap,
    for syntax: Markdown.Syntax
  ) {
    
    /// 1. Check for characters, and character counts (e.g. 2x asterisks for bold `**`)
    /// 2. Wrapping:
    ///   - Create new string from syntax characters and selected content
    ///   - Adjust range to compensate for new glyphs, keeping original text selected
    /// 1. Make sure the text selection makes sense?
    /// 2. Add the right characters (and number of them) around the selection
    /// 3. Ensure the selection is adjusted
    
    let selectedRange = self.selectedRange()
    
    guard selectedRange.length > 0 else {
      print("Zero-length selection not yet supported for syntax wrapping.")
      return
    }
    
    guard let leadingCharacter = syntax.leadingCharacter,
          let trailingCharacter = syntax.trailingCharacter,
          let leadingCount = syntax.leadingCharacterCount,
          let trailingCount = syntax.trailingCharacterCount
    else {
      print("Something failed above")
      return
    }
    
    
    let leadingString = String(repeating: leadingCharacter, count: leadingCount)
    let trailingString = String(repeating: trailingCharacter, count: trailingCount)
    
    print("""
    Let's \(action) selection '\(self.selectedText)', with \(syntax.name) syntax:  '\(leadingString)' and '\(trailingString)'
    """)
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else {
      print("One of the above didn't happen")
      return
    }
    
    let selectionToReplace: NSRange
    let selectionAdjustment: NSRange
    let newText: String
    
    
    switch action {
      case .wrap:
        selectionToReplace = selectedRange
        let newLocation: Int = (selectedRange.location + leadingCount)
        selectionAdjustment = NSRange(location: newLocation, length: selectedRange.length)
        newText = leadingString + self.selectedText + trailingString
        
      case .unwrap:
        
        
        let newLocation: Int = (selectedRange.location - leadingCount)
        let newLength: Int = selectedRange.length + (leadingCount + trailingCount)
        selectionToReplace = NSRange(location: newLocation, length: newLength)
        
        selectionAdjustment = NSRange(location: selectedRange.location - leadingCount, length: selectedRange.length)
        //        selectionAdjustment = NSRange(location: selectedRange.location, length: selectedRange.length)
        
        newText = self.selectedText
        
    }
    
    
    tcm.performEditingTransaction {
      
      
      self.insertText(newText, replacementRange: selectionToReplace)
      self.setSelectedRange(selectionAdjustment)
      
    } // END perform edit
    
    
    
  }
  
  
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
  
  
}
