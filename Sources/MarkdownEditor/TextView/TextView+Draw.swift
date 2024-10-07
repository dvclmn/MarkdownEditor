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
    
    
    guard let textContainer = self.textContainer else {
      fatalError()
    }
    
    guard let layoutManager = self.layoutManager else {
      fatalError()
    }
    
    
    
    // Define your highlight properties
    let cornerRadius: CGFloat = 5.0
    let backgroundColour: NSColor = NSColor.black.withAlphaComponent(0.2)
    let strokeColor: NSColor = NSColor.white.withAlphaComponent(0.05)
    let strokeWidth: CGFloat = 0.0
    
    // Set the highlight color
   
    
    for element in elements {
      
      // Get the glyph range for the character range
      let glyphRange = layoutManager.glyphRange(forCharacterRange: element.range, actualCharacterRange: nil)
      
      
      let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
      
      let textContainerOrigin = self.textContainerOrigin
      let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
      
      let path = NSBezierPath(roundedRect: adjustedRect.insetBy(dx: -5, dy: 0), xRadius: cornerRadius, yRadius: cornerRadius)
      
      backgroundColour.setFill()
      path.fill()
      
//      path.lineWidth = strokeWidth
//      strokeColor.setStroke()
//      path.stroke()

      
      
      // Enumerate over each line fragment within the glyph range
      //      layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (lineRect, usedRect, container, glyphRange, stop) in
      //
      //        // Calculate bounding rectangle for the glyph range
      //        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
      //
      //        // Offset to view coordinates
      //        let textContainerOrigin = self.textContainerOrigin
      //        let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
      //
      //        // Create a rounded rectangle path
      //
      //      }
    }
    
    if configuration.isShowingFrames {
      
      let colour: NSColor = configuration.isEditable ? .red : .purple
      
      let shape: NSBezierPath = NSBezierPath(rect: bounds)
      let shapeColour = colour.withAlphaComponent(0.08)
      shapeColour.set()
      shape.lineWidth = 1.0
      shape.fill()
    }
  }
}
