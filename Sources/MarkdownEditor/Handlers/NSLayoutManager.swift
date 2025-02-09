//
//  LayoutManager.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import AppKit
import BaseStyles
import MarkdownModels

class CodeBackgroundLayoutManager: NSLayoutManager {
  
  let configuration: MarkdownEditorConfiguration
  
  public init(configuration: MarkdownEditorConfiguration) {
    self.configuration = configuration
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("Not implemented")
  }
  
  override func drawBackground(
    forGlyphRange glyphsToShow: NSRange,
    at origin: NSPoint
  ) {
    guard let textStorage = self.textStorage,
          let textContainer = self.textContainers.first else {
      super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
      return
    }
    
    let charRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
    
    for backgroundType in CodeBackground.allCases {
      textStorage.enumerateAttribute(backgroundType.attributeKey, in: charRange, options: []) { (value, range, _) in
        
        if let syntaxType = value as? Bool, syntaxType {
          let glyphRangeForCode = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
          self.enumerateEnclosingRects(forGlyphRange: glyphRangeForCode, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer) { (rect, _) in
            
            let drawRect = rect.offsetBy(dx: origin.x, dy: origin.y).insetBy(dx: -2, dy: -1)
            
            let roundedPath = NSBezierPath(roundedRect: drawRect, xRadius: self.configuration.theme.codeBackgroundRounding, yRadius: self.configuration.theme.codeBackgroundRounding)
            
            self.configuration.theme.codeBackgroundColour.nsColour.setFill()
            roundedPath.fill()
          }
        }
      } // END enumeration
    } // END background types loop
    
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
  }
}
