//
//  Styling.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/10/2024.
//

import AppKit
import Highlightr

extension MarkdownTextView {
  func styleElement() {
    
    //    guard let layoutManager = self.layoutManager else {
    //      fatalError("Issue getting the layout manager")
    //
    //    }
    
    guard let textStorage = self.textStorage else {
      fatalError("Issue getting the text storage")
    }
    textStorage.beginEditing()
    let currentSelection = selectedRange
    
    for element in self.elements {
      if element.syntax == .codeBlock {
        print("Here's a code block")
        
        
        guard let highlightedCode: NSAttributedString = highlightr.highlight(element.string, as: nil) else {
          print("Couldn't get the Highlighted string")
          return
        }
        
        
        
        textStorage.replaceCharacters(in: element.range, with: highlightedCode)
        
        
      } else {
        print("Not a code block, ignoring for now")
      }
    }
    
    setSelectedRange(currentSelection)
    textStorage.endEditing()
    
  }
  
}
