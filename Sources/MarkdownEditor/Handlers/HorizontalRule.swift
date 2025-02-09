//
//  fibg.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/2/2025.
//

import AppKit
import MarkdownModels

class HorizontalRuleAttachment: NSTextAttachment {
  let color: NSColor
  let thickness: CGFloat
  
  init(color: NSColor = .separatorColor, thickness: CGFloat = 1.0) {
    self.color = color
    self.thickness = thickness
    super.init(data: nil, ofType: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func attachmentBounds(
    for textContainer: NSTextContainer?,
    proposedLineFragment lineFrag: CGRect,
    glyphPosition position: CGPoint,
    characterIndex charIndex: Int
  ) -> CGRect {
    return CGRect(x: 0, y: 0, width: lineFrag.width, height: thickness + 8)
  }
}

//class HorizontalRuleLayoutManager: NSLayoutManager {
//  override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//    super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
//    
//    // Iterate through the glyphs in the range
//    enumerateLineFragments(forGlyphRange: glyphsToShow) { rect, usedRect, textContainer, glyphRange, stop in
//      let characterRange = self.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
//      let textStorage = self.textStorage as? MarkdownTextStorage
//      
//      // Check if the character range contains a horizontal rule attachment
//      textStorage?.enumerateAttribute(.attachment, in: characterRange, options: []) { value, range, stop in
//        if let attachment = value as? HorizontalRuleAttachment {
//          // Draw the horizontal rule
//          self.drawHorizontalRule(attachment: attachment, in: usedRect)
//        }
//      }
//    }
//  }
//  
//  private func drawHorizontalRule(attachment: HorizontalRuleAttachment, in rect: CGRect) {
//    guard let context = NSGraphicsContext.current?.cgContext else { return }
//    
//    // Calculate the line position (centered vertically in the frame)
//    let y = rect.midY
//    
//    // Set up the line style
//    context.setLineWidth(attachment.thickness)
//    context.setStrokeColor(attachment.color.cgColor)
//    
//    // Draw the line
//    context.move(to: CGPoint(x: rect.minX, y: y))
//    context.addLine(to: CGPoint(x: rect.maxX, y: y))
//    context.strokePath()
//  }
//}
