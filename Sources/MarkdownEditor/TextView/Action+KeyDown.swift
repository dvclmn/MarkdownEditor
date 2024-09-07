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
    
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager,
//          let selection = tlm.textSelections.first,
//          let selectedRange = selection.textRanges.first,
//          let selectedText = tcm.attributedString(in: selectedRange)?.string
//    else {
//      
//      print("One of the above didn't happen")
//      return
//    }
//    
//    // TODO: I'm mid-way through this, pauding to continue looking at Neon
//    guard let leading = syntax.leadingCharacter,
//    let trailing = syntax.trailingCharacter
//    else {
//      print("")
//      return
//    }
//    let selectedNSRange = NSRange(selectedRange, in: tcm)
//    
//    print("Selected text: \(selectedText)")
//    
////    let textElements: [NSTextElement] = tcm.textElements(for: selectedRange)
//    
//    
//    let newText = leading + selectedText + trailing
//    
//    guard let newStartLocation = tcm.location(selectedRange.location, offsetBy: leading.count),
//    let newEndLocation = tcm.location(selectedRange.endLocation, offsetBy: leading.count),
//            let adjustedRange = NSTextRange(location: newStartLocation, end: newEndLocation)
//    else { return }
//    
//    
//    print("Here is the new text: \(newText)")
//    
//    tcm.performEditingTransaction {
//      
//      
//      
//      textStorage?.replaceCharacters(in: selectedNSRange, with: newText)
//      
//      // Register undo operation
////      let undoManager = self.undoManager
////      undoManager?.registerUndo(withTarget: self, handler: { (targetSelf) in
////        targetSelf.textStorage?.replaceCharacters(in: newRange, with: selectedText)
////        targetSelf.setSelectedRange(selectedRange)
////      })
////      undoManager?.setActionName("Wrap with \(syntax)")
//
//      setSelectedRange(NSRange(adjustedRange, in: tcm))
//      
//      
//      
//      needsDisplay = true
//      tlm.ensureLayout(for: tlm.documentRange)
//
//    } // END perform edit
  }
  
}
