//
//  TextView+Draw.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

import AppKit

extension MarkdownTextView {
  
  public override func draw(_ rect: NSRect) {
    super.draw(rect)
    
    let cornerRadius: CGFloat = 5.0
    let backgroundColour: NSColor = NSColor.black.withAlphaComponent(0.2)
    
    for element in elements {
      
      
      
      let path = NSBezierPath(roundedRect: element.rect, xRadius: cornerRadius, yRadius: cornerRadius)
      
      
      
      backgroundColour.setFill()
      path.fill()
      
    }
//    
//    if configuration.isShowingFrames {
//      
//      let colour: NSColor = configuration.isEditable ? .red : .purple
//      
//      let shape: NSBezierPath = NSBezierPath(rect: bounds)
//      let shapeColour = colour.withAlphaComponent(0.08)
//      shapeColour.set()
//      shape.lineWidth = 1.0
//      shape.fill()
//    }
  }

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
    
    
//    
//    
//    // Get the glyph range for the character range
//    let glyphRange = layoutManager.glyphRange(forCharacterRange: element.range, actualCharacterRange: nil)
//    
//    
//    let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//    
//    let textContainerOrigin = self.textContainerOrigin
//    let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
//    
//    let path = NSBezierPath(roundedRect: adjustedRect.insetBy(dx: -5, dy: 0), xRadius: cornerRadius, yRadius: cornerRadius)
//    
//    
    
    
    
//    let textContainerOrigin = self.textContainerOrigin
//    let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
    
    return boundingRect
  }
  
}
