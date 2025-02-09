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
  
  override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
    // Return a rectangle that spans the full width of the text container
    // Height is determined by the thickness plus some padding
    return CGRect(x: 0, y: 0, width: lineFrag.width, height: thickness + 8)
  }
  
  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    
    // Calculate the line position (centered vertically in the frame)
    let y = cellFrame.midY
    
    // Set up the line style
    context.setLineWidth(thickness)
    context.setStrokeColor(color.cgColor)
    
    // Draw the line
    context.move(to: CGPoint(x: cellFrame.minX, y: y))
    context.addLine(to: CGPoint(x: cellFrame.maxX, y: y))
    context.strokePath()
  }
}

