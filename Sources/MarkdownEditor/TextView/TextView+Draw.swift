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
    
    // Define your highlight properties
//    let cornerRadius: CGFloat = 5.0
//    let backgroundColour: NSColor = NSColor.black.withAlphaComponent(0.2)
//    
//    for element in elements {
//      
//      let path = NSBezierPath(roundedRect: element.rect, xRadius: cornerRadius, yRadius: cornerRadius)
//      
//      backgroundColour.setFill()
//      path.fill()
//      
//    }
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
}
