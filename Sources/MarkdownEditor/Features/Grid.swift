//
//  Grid.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit



struct Grid {
  var colour: NSColor = .lightGray.withAlphaComponent(0.3)
  var spacing: CGFloat = 20
  var lineWidth: CGFloat = 0.5
  var isSubdivided: Bool = false
  var anchor: CGPoint = .init(x: 30, y: 30)
}

extension Grid {
  func drawGrid(for rect: NSRect, in context: CGContext) {
    context.saveGState()
    
    // Calculate initial offsets based on anchor point
    let xOffset = (anchor.x.truncatingRemainder(dividingBy: spacing) + spacing).truncatingRemainder(dividingBy: spacing)
    let yOffset = (anchor.y.truncatingRemainder(dividingBy: spacing) + spacing).truncatingRemainder(dividingBy: spacing)
    
    // Draw main grid lines
    context.setStrokeColor(self.colour.cgColor)
    context.setLineWidth(self.lineWidth)
    
    drawGridLines(in: context, for: rect, interval: self.spacing, xOffset: xOffset, yOffset: yOffset)
    context.strokePath()
    
    if self.isSubdivided {
      
      // Draw fainter lines
      let fainerColor = self.colour.withAlphaComponent(0.2) // Adjust alpha as needed
      context.setStrokeColor(fainerColor.cgColor)
      context.setLineWidth(self.lineWidth / 2) // Thinner lines
      
      let subXOffset = xOffset + (self.spacing / 2)
      let subYOffset = yOffset + (self.spacing / 2)
      drawGridLines(in: context, for: rect, interval: self.spacing, xOffset: subXOffset, yOffset: subYOffset)
      context.strokePath()
    }
    
    context.restoreGState()
  }
  
  private func drawGridLines(
    in context: CGContext,
    for rect: NSRect,
    interval: CGFloat,
    xOffset: CGFloat,
    yOffset: CGFloat
  ) {
    // Draw vertical lines
    for x in stride(from: xOffset, through: rect.width + xOffset, by: interval) {
      let adjustedX = x - xOffset
      context.move(to: CGPoint(x: adjustedX, y: 0))
      context.addLine(to: CGPoint(x: adjustedX, y: rect.height))
    }
    
    // Draw horizontal lines
    for y in stride(from: yOffset, through: rect.height + yOffset, by: interval) {
      let adjustedY = y - yOffset
      context.move(to: CGPoint(x: 0, y: adjustedY))
      context.addLine(to: CGPoint(x: rect.width, y: adjustedY))
    }
  }
}

class GridView: NSView {
  var grid = Grid()
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let context = NSGraphicsContext.current!.cgContext
    
    grid.drawGrid(for: dirtyRect, in: context)
    
  }
}


class GridBackgroundLayoutFragment: NSTextLayoutFragment {
  
  var grid = Grid()
  
  override func draw(at point: CGPoint, in context: CGContext) {
    
    let rect = renderingSurfaceBounds
    
    grid.drawGrid(for: rect, in: context)
    
    /// Draw the actual text content
    super.draw(at: point, in: context)
  }
}

class CodeBlockBackground: NSTextLayoutFragment {
  
  private let paragraphStyle: NSParagraphStyle
  
  let backgroundColor: NSColor = .lightGray.withAlphaComponent(0.2)
  let cornerRadius: CGFloat = 5
  
  init(
    textElement: NSTextElement,
    range rangeInElement: NSTextRange?,
    paragraphStyle: NSParagraphStyle
  ) {
    self.paragraphStyle = paragraphStyle
    super.init(textElement: textElement, range: rangeInElement)
  }
  
  required init?(coder: NSCoder) {
    self.paragraphStyle = NSParagraphStyle.default
    super.init(coder: coder)
  }
  
  override func draw(at point: CGPoint, in context: CGContext) {
    // Draw the grid
    context.saveGState()
    
    let rect = renderingSurfaceBounds
    
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundColor.setFill()
    path.fill()
    
    context.strokePath()
    context.restoreGState()
    
    // Draw the actual text content
    super.draw(at: point, in: context)
  }
}
