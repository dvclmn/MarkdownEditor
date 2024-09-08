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
    
    guard let characters = event.charactersIgnoringModifiers,
          let tlm = self.textLayoutManager,
          let selectionRange = tlm.textSelections.first?.textRanges.first
    else {
      print("Wasn't one of the above, for shortcuts?")
      super.keyDown(with: event)
      return
    }
    
    let wrappableList = Markdown.Syntax.allCases.filter {$0.isWrappable}
    
//    for wrappable in wrappableList {
//      if characters == wrappable.
//    }
//    
    if characters == "`" && !selectionRange.isEmpty {
      self.wrapSelection(in: .inlineCode)
      
    } else if characters == "*" && !selectionRange.isEmpty {
      self.wrapSelection(in: .italic)
    } else {

      super.keyDown(with: event)
    }
  }
  
  
   func wrapSelection(in syntax: Markdown.Syntax) {
    
    print("Let's wrap syntax, for \(syntax)")
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let selection = tlm.textSelections.first,
          let selectedRange = selection.textRanges.first
    else {
      
      print("One of the above didn't happen")
      return
    }
    
    let selectedNSRange = NSRange(selectedRange, provider: tcm)
    
    guard let leadingCharacter = syntax.leadingCharacter,
          let trailingCharacter = syntax.trailingCharacter,
          let leadingCount = syntax.leadingCharacterCount,
          let trailingCount = syntax.trailingCharacterCount,
          let selectedText = self.string.substring(with: selectedNSRange)
    else {
      print("Something failed above")
      return
    }
    
    let leading = String(repeating: leadingCharacter, count: leadingCount)
    let trailing = String(repeating: trailingCharacter, count: trailingCount)
    
    print("Selected text: \(selectedText)")
    
    
    let isWrapped = selectedText.hasPrefix(leading) && selectedText.hasSuffix(trailing)
    let newText: String
    let newRange: NSRange
    
    
    if isWrapped {
      // Unwrap
      newText = String(selectedText.dropFirst(leadingCount).dropLast(trailingCount))
      newRange = NSRange(location: selectedNSRange.location, length: newText.count)
    } else {
      // Wrap
      newText = leading + selectedText + trailing
      newRange = NSRange(location: selectedNSRange.location, length: newText.count)
    }
    
    
    tcm.performEditingTransaction {
      textStorage?.replaceCharacters(in: selectedNSRange, with: newText)
      
      let undoManager = self.undoManager
      undoManager?.registerUndo(withTarget: self) { targetSelf in
        Task { @MainActor in
          targetSelf.wrapSelection(in: syntax)
        }
      }
      undoManager?.setActionName(isWrapped ? "Unwrap \(syntax)" : "Wrap with \(syntax)")
      
      setSelectedRange(newRange)
      
      needsDisplay = true
      tlm.ensureLayout(for: tlm.documentRange)

    } // END perform edit
  }
  
}
