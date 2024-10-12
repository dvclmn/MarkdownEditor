//
//  Styling.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/10/2024.
//

import AppKit
import Highlightr
import Glyph

extension MarkdownTextView {
  
  func styleMarkdown() {
    
    let currentSelection = self.selectedRange
    
    self.styleElement()
    //          self.needsDisplay = true
    
    self.setSelectedRange(currentSelection)

  } // END style debounced
  
  
  func styleElement() {
    
    //    guard let layoutManager = self.layoutManager else {
    //      fatalError("Issue getting the layout manager")
    //
    //    }
    
    guard let textStorage = self.textStorage else {
      fatalError("Issue getting the text storage")
    }
    

    tcm.performEditingTransaction {
      
      for element in self.elements {
        
        if element.syntax == .codeBlock {
          
          textStorage.addAttribute(.font, value: configuration.theme.codeFont, range: element.ranges.all)
          
          
//          guard let highlightedCode: NSAttributedString = highlightr.highlight(element.string, as: nil) else {
//            print("Couldn't get the Highlighted string")
//            return
//          }
//          
//          highlightedCode.enumerateAttribute(.foregroundColor, in: documentNSRange) { value, range, stop in
//            
//            if let color = value as? NSColor {
//              textStorage.addAttribute(.foregroundColor, value: color, range: range)
//            }
//            
//          }
        } else {
          
          
          
          textStorage.addAttributes(element.syntax.contentAttributes(with: self.configuration).attributes, range: element.ranges.content)
          
          textStorage.addAttributes(element.syntax.syntaxAttributes(with: self.configuration).attributes, range: element.ranges.leading)
          textStorage.addAttributes(element.syntax.syntaxAttributes(with: self.configuration).attributes, range: element.ranges.trailing)
          
        }
        
          
//          textStorage.replaceCharacters(in: element.range, with: highlightedCode)

      } // END elements loop

      
    } // END perform editing

    
  } // END styling
  
}
