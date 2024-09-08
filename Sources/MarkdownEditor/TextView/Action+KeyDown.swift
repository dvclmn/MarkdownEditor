//
//  Action+KeyDown.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 5/9/2024.
//

import AppKit
import Rearrange

extension MarkdownTextView {
  
  public override func keyDown(with event: NSEvent) {
    

    guard let pressedKey = event.charactersIgnoringModifiers, pressedKey.count == 1 else {
      print("Key `\(event.keyCode)` not needed for this operation.")
      super.keyDown(with: event)
      return
    }
    
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let pressedShortcut = KeyboardShortcut(key: pressedKey, modifier: modifierFlags)
    
    /// Compact map returns an array with all `nil` items removed, leaving only items that have a value
    let syntaxShortcuts = Markdown.Syntax.allCases.compactMap { $0.shortcut }
    
    if syntaxShortcuts.contains(pressedShortcut) {
      
      
      
//      handleShortcut(pressedShortcut)
      return
    }
    

    
    
    
    /// Now anything below this guard statement will only run if *something*
    /// is selected. This is useful for shortcuts where the user would expect to
    /// be able to type a key (backtick, asterisk), when they're not styling text.
    ///
    /// If nothing is selected, then the pressed key will work as normal.
    ///
    guard self.selectedRange().length > 0 else {
      print("Nothing currently selected. Key pressed: \(event.keyCode)")
      super.keyDown(with: event)
      return
    }
    
    guard let characters = event.charactersIgnoringModifiers else {
      print("Key pressed was not part of `event.charactersIgnoringModifiers`. Key: \(event.keyCode)")
      super.keyDown(with: event)
      return
    }
    
//    let wrappableList = Markdown.Syntax.allCases.filter {$0.isWrappable}
    
    
    
    if let syntax = wrappableList.first(where: { $0.shortcut?.key == characters.first }) {
      
      print(syntax.name)
      
    } else {
      print("Key pressed didn't match any of the wrappable syntax characters. Key pressed was: \(event.keyCode)")
      super.keyDown(with: event)
    }
    
    //
    //
    //
    //
    //
    //    for wrappable in wrappableList {
    //      if let leading = wrappable.leadingCharacter, characters == String(leading) {
    //        self.handleWrapping(for: wrappable)
    //      } else {
    //        super.keyDown(with: event)
    //      }
    //    }
    //
    
  } // END key down override
  
  enum WrapAction {
    case wrap
    case unwrap
  }
  
  
  func handleWrapping(_ action: WrapAction = .wrap, for syntax: Markdown.Syntax) {
    
    /// 1. Check for characters, and character counts (e.g. 2x asterisks for bold `**`)
    /// 2. Wrapping:
    ///   - Create new string from syntax characters and selected content
    ///   - Adjust range to compensate for new glyphs, keeping original text selected
    
    guard let leadingCharacter = syntax.leadingCharacter,
          let trailingCharacter = syntax.trailingCharacter,
          let leadingCount = syntax.leadingCharacterCount,
          let trailingCount = syntax.trailingCharacterCount
    else {
      print("Something failed above")
      return
    }
    
    let leading = String(repeating: leadingCharacter, count: leadingCount)
    let trailing = String(repeating: trailingCharacter, count: trailingCount)
    
    print("Let's wrap \(syntax.name), with \(leading) and \(trailing)")
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let selection = tlm.textSelections.first,
          let selectedRange = selection.textRanges.first
    else {
      print("One of the above didn't happen")
      return
    }
    
    let selectedNSRange = NSRange(selectedRange, provider: tcm)
    guard let selectedText = self.string.substring(with: selectedNSRange) else {
      print("Issue getting selected text")
      return
    }
    
    print("Selected text to wrap: \(selectedText)")
    
    let newSelection: NSRange
    let newText: String
    
    switch action {
      case .wrap:
        
        
        
        /// Adjusts the selection to compensate for the new syntax characters.
        ///
        /// Using the original `selectedRange` as a fallback here, probably
        /// something more elegant that could be done.
        ///
        newSelection = selectedNSRange.shifted(by: leadingCount) ?? selectedNSRange
        
        newText = leading + selectedText + trailing
        
        
      case .unwrap:
        
        /// We want to expand our selection by the correct number of characters,
        /// and then replace it, just like a wrap(?)
        
        let newLocation: Int = selectedNSRange.location - leadingCount
        let newLength: Int = selectedNSRange.length + (leadingCount + trailingCount)
        
        newText = String(selectedText)
        
        /// Adjusts the selection to compensate for the new syntax characters.
        ///
        /// Using the original `selectedRange` as a fallback here, probably
        /// something more elegant that could be done.
        ///
        
        newSelection = NSRange(location: newLocation, length: newLength)
        
    }
    
    
    
    
    tcm.performEditingTransaction {
      
      self.textStorage?.replaceCharacters(in: newSelection, with: newText)
      
      self.setSelectedRange(newSelection)
      
      let undoManager = self.undoManager
      undoManager?.registerUndo(withTarget: self) { targetSelf in
        
        Task { @MainActor in
          
          targetSelf.handleWrapping(.unwrap, for: syntax)
          targetSelf.setSelectedRange(selectedNSRange)
          
        }
      }
      undoManager?.setActionName("Wrap with \(syntax.name)")
      
      needsDisplay = true
      tlm.ensureLayout(for: tlm.documentRange)
      
    } // END perform edit
  }
  
}
