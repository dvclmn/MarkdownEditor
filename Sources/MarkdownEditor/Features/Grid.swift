//
//  Grid.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

class InfiniteGridView: NSView {
  var grid: Grid
  weak var scrollView: NSScrollView?
  private var boundsObservation: NSKeyValueObservation?
  
  init(grid: Grid = Grid(), scrollView: NSScrollView) {
    self.grid = grid
    self.scrollView = scrollView
    super.init(frame: .zero)
    self.wantsLayer = true
    self.layer?.contents = nil
    
    setupBoundsObserver()

  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    guard let context = NSGraphicsContext.current?.cgContext,
          let scrollView = scrollView else { return }
    
    let visibleRect = scrollView.contentView.bounds
    let contentBounds = scrollView.documentView?.bounds ?? .zero
    
    // Adjust the drawing origin based on the scroll position
    context.translateBy(x: -visibleRect.origin.x, y: -visibleRect.origin.y)
    
    // Calculate the area to draw (visible area plus some overflow)
    let drawingRect = NSRect(
      x: visibleRect.origin.x - grid.spacing,
      y: visibleRect.origin.y - grid.spacing,
      width: visibleRect.width + 2 * grid.spacing,
      height: visibleRect.height + 2 * grid.spacing
    )
    
    // Clip to the content bounds
    context.clip(to: contentBounds)
    
    // Draw the grid
    grid.drawGrid(for: drawingRect, in: context)
  }
  
  private func setupBoundsObserver() {
    boundsObservation = scrollView?.documentView?.observe(\.bounds, options: [.new]) { [weak self] _, change in
      guard let newBounds = change.newValue else { return }
      self?.updateFrame(with: newBounds)
    }
  }
  
  func updateFrame(with newBounds: NSRect) {
    self.frame = newBounds
    self.needsDisplay = true
  }
  
  deinit {
    boundsObservation?.invalidate()
  }

}

struct Grid {
  var colour: NSColor = .lightGray.withAlphaComponent(0.3)
  var spacing: CGFloat = 20
  var lineWidth: CGFloat = 0.5
  var isSubdivided: Bool = false
  var shouldScroll: Bool = false
  var offset: CGFloat = .zero
}

extension Grid {
  func drawGrid(for rect: NSRect, in context: CGContext) {
    context.saveGState()
    
    // Draw main grid lines
    context.setStrokeColor(self.colour.cgColor)
    context.setLineWidth(self.lineWidth)
    
    drawGridLines(in: context, for: rect, interval: self.spacing, offset: self.offset)

    context.strokePath()
    
    if self.isSubdivided {
      // Draw fainter lines
      let fainerColor = self.colour.withAlphaComponent(0.2) // Adjust alpha as needed
      context.setStrokeColor(fainerColor.cgColor)
      context.setLineWidth(self.lineWidth / 2) // Thinner lines
      
      let halfSpacing = self.spacing / 2
      drawGridLines(in: context, for: rect, interval: self.spacing, offset: halfSpacing + self.offset)
    }
    
    context.strokePath()
    context.restoreGState()
  }
  
  private func drawGridLines(
    in context: CGContext,
    for rect: NSRect,
    interval: CGFloat,
    offset: CGFloat = 0
  ) {
    // Draw vertical lines
    for x in stride(from: offset, through: rect.width, by: interval) {
      context.move(to: CGPoint(x: x, y: 0))
      context.addLine(to: CGPoint(x: x, y: rect.height))
    }
    
    // Draw horizontal lines
    for y in stride(from: offset, through: rect.height, by: interval) {
      context.move(to: CGPoint(x: 0, y: y))
      context.addLine(to: CGPoint(x: rect.width, y: y))
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
