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
      super.keyDown(with: event)
      return
    }
    
    let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    let shortcut = KeyboardShortcut(key: characters, modifier: modifierFlags)
    let hasSelection: Bool = !selectionRange.isEmpty
    
    
    if let syntax = MarkdownSyntax.syntax(for: shortcut) {
      syntaxToWrap = syntax
    } else {
      super.keyDown(with: event)
    }
    
    
  }
  
  
  func wrapSelection(in syntax: MarkdownSyntax) {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage,
          let selection = tlm.textSelections.first,
          let selectedRange = selection.textRanges.first,
          let selectedText = tcm.attributedString(in: selectedRange)?.string
    else { return }
    
    let leading: String = syntax.leadingCharacters
    let trailing: String = syntax.trailingCharacters
    
    print("Selected text: \(selectedText)")
    
    let newText = leading + selectedText + trailing
    let newAttrString = NSAttributedString(string: newText)
    
    tcm.performEditingTransaction {
      tcm.replaceContents(
        in: selectedRange,
        with: [NSTextParagraph(attributedString: newAttrString)]
      )
    }
  }
  
}
