//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import Foundation
import AppKit
import BaseHelpers
import TextCore


public struct Markdown {
  
  struct Element: Hashable {
    var syntax: Markdown.Syntax
    var range: NSRange
    var rect: NSRect
  }
  
}



extension MarkdownTextView {
  
  func getRect(
    for range: NSRange
  ) -> NSRect {
    
    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer
    else {
      fatalError("Couldn't get 'em")
    }
    
    let boundingRect = layoutManager.boundingRect(
      forGlyphRange: range,
      in: textContainer
    )

    let textContainerOrigin = self.textContainerOrigin
    let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
    
    return adjustedRect
  }
  
  func addMarkdownElement(_ element: Markdown.Element) {
    let inserted = elements.insert(element)
    if inserted.inserted {
      needsDisplay = true
    }
    // If already present, no action needed
  }
  
  // Alternatively, for entire parsing runs, consider replacing the set
  func setMarkdownElements(_ newElements: Set<Markdown.Element>) {
    elements = newElements
    needsDisplay = true
  }

}
