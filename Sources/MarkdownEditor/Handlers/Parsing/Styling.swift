//
//  Styling.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 1/9/2024.
//


import AppKit
import BaseHelpers
import TextCore


extension MarkdownTextView {
  

  
  
  
  
  
  
  
  
  
  // Helper function to compare Any values
  func isEqual(_ lhs: Any?, _ rhs: Any) -> Bool {
    switch (lhs, rhs) {
      case let (lhs as NSColor, rhs as NSColor):
        return lhs == rhs
      case let (lhs as NSFont, rhs as NSFont):
        return lhs == rhs
      case let (lhs as NSParagraphStyle, rhs as NSParagraphStyle):
        return lhs == rhs
      case let (lhs as NSNumber, rhs as NSNumber):
        return lhs == rhs
      case let (lhs as String, rhs as String):
        return lhs == rhs
        // Add more cases as needed for other attribute types
      default:
        return false
    }
  }
  

  
}
