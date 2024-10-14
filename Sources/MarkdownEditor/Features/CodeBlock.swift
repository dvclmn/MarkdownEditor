//
//  CodeBlock.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import AppKit
//
//
class CodeBlockBackground: NSTextLayoutFragment {
  
  let backgroundColor: NSColor = .lightGray.withAlphaComponent(0.2)
  let cornerRadius: CGFloat = 5
  let viewWidth: CGFloat
  var isActive: Bool
  
  init(
    textElement: NSTextElement,
    range rangeInElement: NSTextRange?,
    viewWidth: CGFloat,
    isActive: Bool = false
  ) {
    self.viewWidth = viewWidth
    self.isActive = isActive
    super.init(textElement: textElement, range: rangeInElement)
  }
  
  required init?(coder: NSCoder) {
    fatalError("Don't use this init")
  }
  
  override func draw(at point: CGPoint, in context: CGContext) {
    
    context.saveGState()
    
    let colour = isActive ? NSColor.blue.withAlphaComponent(0.4) : backgroundColor
    
//    let path = NSBezierPath()
    
        let path = NSBezierPath(
          roundedRect: NSRect(
            origin: renderingSurfaceBounds.origin,
            size: CGSize(
              width: 100,
    //          width: viewWidth,
              height: renderingSurfaceBounds.height)
          ),
          xRadius: cornerRadius,
          yRadius: cornerRadius
        )
    
    path.move(to: point)
    
    path.line(to: point.shiftRight(20))
    
    path.curve(to: point.shift(dx: 40, dy: 80), controlPoint: point.shiftRight(viewWidth))
    
    path.close()
    
    colour.setFill()
    path.fill()
    
    context.strokePath()
    context.restoreGState()
    
    // Draw the actual text content
    super.draw(at: point, in: context)
  }
  
}
