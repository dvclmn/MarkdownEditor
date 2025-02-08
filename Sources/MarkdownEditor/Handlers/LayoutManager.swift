//
//  LayoutManager.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import AppKit
import BaseStyles

extension NSAttributedString.Key {
  static let inlineCode = NSAttributedString.Key("inlineCode")
}

class InlineCodeLayoutManager: NSLayoutManager {
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
    
    textStorage.enumerateAttribute(.inlineCode, in: charRange, options: []) { (value, range, _) in
      // Check for NSNumber and convert to Bool
      if let isInlineCode = (value as? NSNumber)?.boolValue, isInlineCode {
        let glyphRangeForCode = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        self.enumerateEnclosingRects(forGlyphRange: glyphRangeForCode, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer) { (rect, _) in
          
          let drawRect = rect.offsetBy(dx: origin.x, dy: origin.y).insetBy(dx: -2, dy: -1)
          
          let roundedPath = NSBezierPath(roundedRect: drawRect, xRadius: 4, yRadius: 4)
          
          NSColor(red: 208/255, green: 201/255, blue: 200/255, alpha: 1.0).setFill()
          roundedPath.fill()
        }
      }
    }
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
  }
}
