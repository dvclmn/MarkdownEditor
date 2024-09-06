//
//  Action+KeyDown.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 5/9/2024.
//

import AppKit

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
    
    if characters == "`" && !selectionRange.isEmpty {
      self.wrapSelection(in: .inlineCode)
    } else {

      super.keyDown(with: event)
    }
  }
  
  
  func wrapSelection(in syntax: MarkdownSyntax) {
    
    print("Let's wrap syntax, for \(syntax)")
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let selection = tlm.textSelections.first,
          let selectedRange = selection.textRanges.first,
          let selectedText = tcm.attributedString(in: selectedRange)?.string
    else {
      
      print("One of the above didn't happen")
      return
    }
    
    let leading: String = syntax.leadingCharacters
    let trailing: String = syntax.trailingCharacters
    let selectedNSRange = NSRange(selectedRange, in: tcm)
    
    print("Selected text: \(selectedText)")
    
//    let textElements: [NSTextElement] = tcm.textElements(for: selectedRange)
    
    
    let newText = leading + selectedText + trailing
    
    guard let newStartLocation = tcm.location(selectedRange.location, offsetBy: leading.count),
    let newEndLocation = tcm.location(selectedRange.endLocation, offsetBy: leading.count),
            let adjustedRange = NSTextRange(location: newStartLocation, end: newEndLocation)
    else { return }
    
    
    print("Here is the new text: \(newText)")
    
    tcm.performEditingTransaction {
      
      
      
      textStorage?.replaceCharacters(in: selectedNSRange, with: newText)
      
      // Register undo operation
//      let undoManager = self.undoManager
//      undoManager?.registerUndo(withTarget: self, handler: { (targetSelf) in
//        targetSelf.textStorage?.replaceCharacters(in: newRange, with: selectedText)
//        targetSelf.setSelectedRange(selectedRange)
//      })
//      undoManager?.setActionName("Wrap with \(syntax)")

      setSelectedRange(NSRange(adjustedRange, in: tcm))
      
      
      
      needsDisplay = true
      tlm.ensureLayout(for: tlm.documentRange)

    } // END perform edit
  }
  
}
