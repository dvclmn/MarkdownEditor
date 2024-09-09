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
  
  public override func keyDown(with event: NSEvent) {
    
    guard let pressedKey = event.charactersIgnoringModifiers, pressedKey.count == 1 else {
      print("Key `\(event.keyCode)` not needed for this operation.")
      return super.keyDown(with: event)
    }
    
    let hasSelection: Bool = self.selectedRange().length > 0
    guard hasSelection else {
      print("Zero-length selection not yet supported for keyboard shortcuts.")
      return super.keyDown(with: event)
    }
    
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let pressedShortcut = Keyboard.Shortcut(.character(Character(pressedKey)), modifierFlags: modifierFlags)
    
    if let matchingSyntax = Markdown.Syntax.findMatchingSyntax(for: pressedShortcut) {
      handleWrapping(for: matchingSyntax)
    } else {
      print("Shortcut didn't match any syntax shortcuts, handing the event back to the system.")
      super.keyDown(with: event)
    }
    
  } // END key down override
  
  enum WrapAction {
    case wrap
    case unwrap
  }
  
  func getSelectedText() -> String? {

    // Get the selected range from the text view
    let selectedRange = self.selectedRange()
    
    // Ensure the selected range is within the bounds of the text
    if selectedRange.location == NSNotFound || selectedRange.length == 0 {
      return nil
    }
    
    let fullText = self.attributedString()
    let textLength = fullText.length
    
    // Calculate the intersection of the textView's range and the selected range
    let intersectionRange = NSIntersectionRange(selectedRange, NSRange(location: 0, length: textLength))
    
    // If the intersection is valid and has length, extract the attributed substring
    if intersectionRange.length > 0 {
      let substring = fullText.attributedSubstring(from: intersectionRange)
      return substring.string
    }
    
    // If the intersection is empty or invalid, return nil
    return nil
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
    
    guard let selectedText = self.getSelectedText() else {
      print("Could not get selected text for range: \(selectedRange)")
      return
    }
    
    print("""
    Let's wrap selection '\(selectedText)', with \(syntax.name) syntax:  '\(leadingString)' and '\(trailingString)'
    """)
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
    else {
      print("One of the above didn't happen")
      return
    }
    
    let newSelection: NSRange
    let newText: String
    
    switch action {
      case .wrap:
        
        /// Adjusts the selection to compensate for the new syntax characters.
        ///
        /// Using the original `selectedRange` as a fallback here, probably
        /// something more elegant that could be done.
        ///
        /// > Important: The order in which the text and the selection is set matters.
        /// > Set the text, and then set the selection adjustments accordingly.
        
        newText = leadingString + selectedText + trailingString
        newSelection = selectedRange.shifted(by: leadingCount) ?? selectedRange
        
        
      case .unwrap:
        
        /// We want to expand our selection by the correct number of characters,
        /// and then replace it, just like a wrap(?)
        
        //        let newLocation: Int = selectedNSRange.location - leadingCount
        //        let newLength: Int = selectedNSRange.length + (leadingCount + trailingCount)
        
        newText = String(selectedText)
        
        /// Adjusts the selection to compensate for the new syntax characters.
        ///
        /// Using the original `selectedRange` as a fallback here, probably
        /// something more elegant that could be done.
        ///
        
        newSelection = selectedRange
        //        newSelection = NSRange(location: newLocation, length: newLength)
        
    }
    
    
    
    
    tcm.performEditingTransaction {
      
      self.textStorage?.replaceCharacters(in: newSelection, with: newText)
      
      self.setSelectedRange(newSelection)
      
      let undoManager = self.undoManager
      undoManager?.registerUndo(withTarget: self) { targetSelf in
        
        Task { @MainActor in
          
          //          targetSelf.handleWrapping(.unwrap, for: syntax)
          //          targetSelf.setSelectedRange(selectedNSRange)
          
        }
      }
      undoManager?.setActionName("Wrap with \(syntax.name)")
      
      needsDisplay = true
      tlm.ensureLayout(for: tlm.documentRange)
      
    } // END perform edit
  }
  
}
