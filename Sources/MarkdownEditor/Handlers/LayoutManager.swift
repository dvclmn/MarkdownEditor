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
    
    /// Convert the glyph range to a character range.
    let charRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
    
    /// Enumerate over runs that have our custom attribute.
    textStorage.enumerateAttribute(.inlineCode, in: charRange, options: []) { (value, range, _) in
      
      if let isInlineCode = value as? Bool, isInlineCode {
        /// Get the glyph range corresponding to this character range.
        let glyphRangeForCode = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        
        /// Enumerate all the rectangles that enclose the glyphs.
        self.enumerateEnclosingRects(forGlyphRange: glyphRangeForCode, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer) { (rect, _) in
          
          /// Offset by the drawing origin and add some padding
          let drawRect = rect.offsetBy(dx: origin.x, dy: origin.y).insetBy(dx: -2, dy: -1)
          
          /// Create a rounded path.
          let roundedPath = NSBezierPath(roundedRect: drawRect, xRadius: 4, yRadius: 4)
          
          /// Set background colour.
          NSColor(red: 208, green: 201, blue: 200, alpha: 1.0).setFill()
          roundedPath.fill()
        }
      }
    }
    super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
  }
}
