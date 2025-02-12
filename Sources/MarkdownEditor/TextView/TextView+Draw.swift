//
//  TextView+Draw.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//
//
//import AppKit

//extension MarkdownTextView {
  
//  public override func draw(_ rect: NSRect) {
//    super.draw(rect)
//    
//    codeBlockBackgrounds()
//    debugFrames()
//
//  } // END draw override
//  
  
//  func codeBlockBackgrounds() {
//    
//    if configuration.drawsCodeBlockBackgrounds {
//
//      // MARK: - Code block backgrounds
//      let cornerRadius: CGFloat = 5.0
//      let backgroundColour: NSColor = NSColor.black.withAlphaComponent(0.2)
//      
//      
//      
//      for element in elements where element.syntax == .codeBlock {
//        
//        guard let rect = element.getRect(with: self.frame.width, config: self.configuration) else {
//          break
//        }
//        
//        let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
//        
//        backgroundColour.setFill()
//        path.fill()
//        
//      }
//    }
//  } // END code block bg's
//  
  
  //  func getRect(
  //    for range: NSRange
  //  ) -> NSRect {
  //
  //    guard let layoutManager = self.layoutManager,
  //          let textContainer = self.textContainer
  //    else {
  //      fatalError("Couldn't get 'em")
  //    }
  //
  //    /// IMPORTANT:
  //    ///
  //    /// This innocent little `boundingRect` function was (i'm pretty sure) causing a long-lasting
  //    /// error/crash, `_fillLayoutHoleForCharacterRange` (etc) and
  //    /// `attempted layout while textStorage is`...
  //    /// So I'll have to make sure I only call this when it's safe (or use something different).
  //    /// https://lists.apple.com/archives/cocoa-dev/2011/Aug/msg01126.html
  //    ///
  //    let boundingRect = layoutManager.boundingRect(
  //      forGlyphRange: range,
  //      in: textContainer
  //    )
  //
  //    let textContainerOrigin = self.textContainerOrigin
  //    let adjustedRect = boundingRect.offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
  //
  //
  //    return adjustedRect
  //  }
  
  
//  func debugFrames() {
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
//      
//    } // END is showing frames check
//    
//  }
  
//  func drawLineBreaks() {
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager else {
//      fatalError("Couldn't get TextKit 2 components")
//    }
//    
//    tlm.ensureLayout(for: tcm.documentRange)
//    
//    tlm.enumerateTextLayoutFragments(
//      from: tcm.documentRange.location,
//      options: [.ensuresLayout, .ensuresExtraLineFragment]
//    ) { fragment in
//      for lineFragment in fragment.textLineFragments {
//        let lineRect = lineFragment.typographicBounds
//        
//        // Convert the rect to view coordinates
//        //          let convertedRect = self.convert(lineRect, from: nil)
//        
//        let lineHeightShape = NSBezierPath(rect: lineRect)
//        
//        let fillColour = NSColor.cyan.withAlphaComponent(0.1)
//        let strokeColour = NSColor.red.withAlphaComponent(0.3)
//        
//        fillColour.setFill()
//        lineHeightShape.fill()
//        
//        strokeColour.setStroke()
//        lineHeightShape.stroke()
//      }
//      
//      return true // Continue enumeration
//    }
//    
//  }
  
//}
