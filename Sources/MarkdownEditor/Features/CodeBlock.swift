//
//  CodeBlock.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import AppKit

class CodeBlockBackground: NSTextLayoutFragment {
  
  private let paragraphStyle: NSParagraphStyle
  
  static var fragmentCount: Int = 0
  private let fragmentIndex: Int
  
  let backgroundColor: NSColor = .lightGray.withAlphaComponent(0.2)
  let cornerRadius: CGFloat = 5
  
  init(
    textElement: NSTextElement,
    range rangeInElement: NSTextRange?,
    paragraphStyle: NSParagraphStyle
  ) {
    CodeBlockBackground.fragmentCount += 1
    self.fragmentIndex = CodeBlockBackground.fragmentCount
    self.paragraphStyle = paragraphStyle
    super.init(textElement: textElement, range: rangeInElement)
  }
  
  required init?(coder: NSCoder) {
    fatalError("Don't use this init")
  }
  
  override func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    
    let rect = renderingSurfaceBounds
    
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundColor.setFill()
    path.fill()
    
    // Draw the fragment index
    let indexString = "\(fragmentIndex)"
    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 10),
      .foregroundColor: NSColor.darkGray
    ]
    let size = indexString.size(withAttributes: attributes)
    let indexPoint = CGPoint(x: rect.maxX - size.width - 5, y: rect.minY + 5)
    indexString.draw(at: indexPoint, withAttributes: attributes)
    
    context.strokePath()
    context.restoreGState()
    
    // Draw the actual text content
    super.draw(at: point, in: context)
  }
  
  
  //  override func draw(at point: CGPoint, in context: CGContext) {
  //    // Draw the grid
  //    context.saveGState()
  //
  //    let rect = renderingSurfaceBounds
  //
  //
  //
  //    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
  //    backgroundColor.setFill()
  //    path.fill()
  //
  //    context.strokePath()
  //    context.restoreGState()
  //
  //    // Draw the actual text content
  //    super.draw(at: point, in: context)
  //  }
}
