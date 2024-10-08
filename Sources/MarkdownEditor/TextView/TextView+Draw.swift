//
//  TextView+Draw.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

import AppKit

extension MarkdownTextView {
  
//  public override func draw(_ rect: NSRect) {
//    super.draw(rect)
//    
//    
//    
//    // MARK: - Code block backgrounds
//    let cornerRadius: CGFloat = 5.0
//    let backgroundColour: NSColor = NSColor.black.withAlphaComponent(0.2)
//    
//    for element in elements where element.syntax == .codeBlock {
//      
//      let path = NSBezierPath(roundedRect: element.rect, xRadius: cornerRadius, yRadius: cornerRadius)
//      
//      backgroundColour.setFill()
//      path.fill()
//      
//    }
//    
//    debugFrames()
//    
//    // MARK: - Showing Frames
//    
//  } // END draw override
  
  
  
  func getRect(
    for range: NSRange
  ) -> NSRect {
    
    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer
    else {
      fatalError("Couldn't get 'em")
    }
    
    /// IMPORTANT:
    ///
    /// This innocent little `boundingRect` function was (i'm pretty sure) causing a long-lasting
    /// error/crash, `_fillLayoutHoleForCharacterRange` (etc) and
    /// `attempted layout while textStorage is`...
    /// So I'll have to make sure I only call this when it's safe (or use something different).
    /// https://lists.apple.com/archives/cocoa-dev/2011/Aug/msg01126.html
    ///
    let boundingRect = layoutManager.boundingRect(
      forGlyphRange: range,
      in: textContainer
    )
    
    let textContainerOrigin = self.textContainerOrigin
    let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
    
    
    return adjustedRect
  }
  
  
  func debugFrames() {
    
    if configuration.isShowingFrames {
      
      guard let layoutManager = self.layoutManager
      else {
        fatalError("Couldn't get 'em")
      }
      
      let numberOfGlyphs = layoutManager.numberOfGlyphs
      var index = 0
      
      while index < numberOfGlyphs {
        var effectiveRange = NSRange(location: 0, length: 0)
        
        let lineRect = layoutManager.lineFragmentRect(
          forGlyphAt: index,
          effectiveRange: &effectiveRange
        )
        /// Adding the below, causes a bunch of weird visual bugs, and very unpredictable
        /// layout behaviour
        //      lineRect = self.convert(lineRect, from: nil) // Convert to view coordinates
        
        let lineHeightShape = NSBezierPath(rect: lineRect)
        
        let fillColour = NSColor.cyan.withAlphaComponent(0.1)
        let strokeColour = NSColor.red.withAlphaComponent(0.3)
        
        fillColour.setFill()
        lineHeightShape.fill()
        
        strokeColour.setStroke()
        lineHeightShape.stroke()
        
        index = NSMaxRange(effectiveRange)
      }
      
      
      let colour: NSColor = configuration.isEditable ? .red : .purple
      
      let shape: NSBezierPath = NSBezierPath(rect: bounds)
      let shapeColour = colour.withAlphaComponent(0.08)
      shapeColour.set()
      shape.lineWidth = 1.0
      shape.fill()
      
      
    } // END is showing frames check
    
    
  }
  
}
