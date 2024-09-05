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
    
    print("Key pressed: \(characters)")
    
//    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
//    let shortcut = KeyboardShortcut(key: characters, modifier: modifierFlags)
    
    if characters == "`" && !selectionRange.isEmpty {
      self.wrapSelection(in: .inlineCode)
    } else {
      print("Character wasn't a backtick, do the normal thing.")
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
    
    print("Selected text: \(selectedText)")
    
//    let textElements: [NSTextElement] = tcm.textElements(for: selectedRange)
    
    
    let newText = leading + selectedText + trailing
    let newAttrString = NSAttributedString(string: newText)
    
    print("Here is the new text: \(newText)")
    print("The new attributed string: \(newAttrString)")
    
    tcm.performEditingTransaction {
      
      textStorage?.replaceCharacters(in: NSRange(selectedRange, in: tcm), with: newText)


    }
  }
  
}
