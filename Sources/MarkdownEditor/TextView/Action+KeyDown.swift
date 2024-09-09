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
      super.keyDown(with: event)
      return
    }
    
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let pressedShortcut = Keyboard.Shortcut(.character(Character(pressedKey)), modifierFlags: modifierFlags)
    
    
    handleShortcut(pressedShortcut) {
      super.keyDown(with: event)
    }
    
  } // END key down override
  
  enum WrapAction {
    case wrap
    case unwrap
  }
  
  func handleShortcut(_ shortcut: Keyboard.Shortcut, defaultAction: () -> Void) {
    
    print("Pressed shortcut: \(shortcut)")
    
    guard let matchingSyntax = findMatchingSyntax(for: shortcut) else {
      print("Shortcut didn't match any syntax shortcuts, handing the event back to the system.")
      defaultAction()
      return
    }
    
    if meetsSelectionRequirement(for: shortcut) {
      handleWrapping(for: matchingSyntax, shortcut: shortcut)
    } else {
      defaultAction()
      return
    }
  }
  
  
  private func findMatchingSyntax(for shortcut: Keyboard.Shortcut) -> Markdown.Syntax? {
    for syntax in Markdown.Syntax.allCases {
      if syntax.shortcuts.contains(shortcut) {
        return syntax
      }
    }
    return nil
  }
  
  private func meetsSelectionRequirement(for shortcut: Keyboard.Shortcut) -> Bool {
    
    let somethingIsSelected = selectedRange().length > 0
    
    if shortcut.requiresTextSelection && !somethingIsSelected {
      print("The shortcut `\(shortcut)` requires a selection, but nothing is selected.")
      return false
    }
    
    if shortcut.requiresTextSelection {
      print("The shortcut `\(shortcut)` requires a selection, and there is something selected: \(selectedRange())")
    } else {
      print("The shortcut `\(shortcut)` does not require a selection.")
    }
    
    return true
  }
  
 
  func handleWrapping(
    _ action: WrapAction = .wrap,
    for syntax: Markdown.Syntax,
    shortcut: Keyboard.Shortcut
  ) {
    
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
