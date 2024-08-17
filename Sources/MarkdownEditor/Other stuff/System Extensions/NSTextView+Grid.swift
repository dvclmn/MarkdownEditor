import AppKit

class GridBackgroundLayoutFragment: NSTextLayoutFragment {
  var gridColor: NSColor = .lightGray.withAlphaComponent(0.3)
  var gridSpacing: CGFloat = 20.0
  
  override func draw(at point: CGPoint, in context: CGContext) {
    // Draw the grid
    context.saveGState()
    
    context.setStrokeColor(gridColor.cgColor)
    context.setLineWidth(0.5)
    
    let rect = renderingSurfaceBounds
    
    // Draw vertical lines
    for x in stride(from: 0, through: rect.width, by: gridSpacing) {
      context.move(to: CGPoint(x: x, y: 0))
      context.addLine(to: CGPoint(x: x, y: rect.height))
    }
    
    // Draw horizontal lines
    for y in stride(from: 0, through: rect.height, by: gridSpacing) {
      context.move(to: CGPoint(x: 0, y: y))
      context.addLine(to: CGPoint(x: rect.width, y: y))
    }
    
    context.strokePath()
    context.restoreGState()
    
    // Draw the actual text content
    super.draw(at: point, in: context)
  }
}
