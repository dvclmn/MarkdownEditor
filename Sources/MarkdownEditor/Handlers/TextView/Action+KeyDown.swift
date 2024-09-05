//
//  Action+KeyDown.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 5/9/2024.
//

import AppKit

extension MarkdownTextView {
  
  public override func keyDown(with event: NSEvent) {
    
    guard let characters = event.charactersIgnoringModifiers else {
      super.keyDown(with: event)
      return
    }
    
    let commandKey = NSEvent.ModifierFlags.command.rawValue
    let commandPressed = event.modifierFlags.rawValue & commandKey == commandKey
    
    var reservedCharacters: String {
      
      var result: String = ""
      
      for syntax in MarkdownSyntax.allCases {
        
        if let key = syntax.shortcut?.key {
          result = key
        }
      }
      return result
    }
    
    
    if commandPressed {
      
      if characters.contains(reservedCharacters) {
        
        self.syntaxToWrap = KeyboardShortcut(key: characters, modifier: .command, syntax: <#T##MarkdownSyntax#>)
        
        print("Shortcut pressed: \(self)")
        
      } else {
        super.keyDown(with: event)
      }
    }
  }
  
}
