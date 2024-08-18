//
//  Grid.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

class GridView: NSView {
  var gridColor: NSColor = .lightGray.withAlphaComponent(0.3)
  var gridSpacing: CGFloat = 20.0
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let context = NSGraphicsContext.current!.cgContext
    context.setStrokeColor(gridColor.cgColor)
    context.setLineWidth(0.5)
    
    // Draw vertical lines
    for x in stride(from: 0, through: bounds.width, by: gridSpacing) {
      context.move(to: CGPoint(x: x, y: 0))
      context.addLine(to: CGPoint(x: x, y: bounds.height))
    }
    
    // Draw horizontal lines
    for y in stride(from: 0, through: bounds.height, by: gridSpacing) {
      context.move(to: CGPoint(x: 0, y: y))
      context.addLine(to: CGPoint(x: bounds.width, y: y))
    }
    
    context.strokePath()
  }
}

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
      context.move(to: CGPoint(x: x + point.x, y: point.y))
      context.addLine(to: CGPoint(x: x + point.x, y: rect.height + point.y))
    }
    
    // Draw horizontal lines
    for y in stride(from: 0, through: rect.height, by: gridSpacing) {
      context.move(to: CGPoint(x: point.x, y: y + point.y))
      context.addLine(to: CGPoint(x: rect.width + point.x, y: y + point.y))
    }
    
    context.strokePath()
    context.restoreGState()
    
    // Draw the actual text content
    super.draw(at: point, in: context)
  }
}

class CodeBlockBackground: NSTextLayoutFragment {
  
  private let paragraphStyle: NSParagraphStyle
  var showsInvisibleCharacters: Bool = false
  
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
    self.showsInvisibleCharacters = false
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
    
    if showsInvisibleCharacters {
      drawInvisibles(at: point, in: context)
    }
    
    context.restoreGState()
    
    // Draw the actual text content
    super.draw(at: point, in: context)
  }
  
  private func drawInvisibles(at point: CGPoint, in context: CGContext) {
    guard let textLayoutManager = textLayoutManager else {
      return
    }
    
    context.saveGState()
    
    for lineFragment in textLineFragments where !lineFragment.isExtraLineFragment {
      
      let string = lineFragment.attributedString.string
      if let textLineTextRange = lineFragment.textRange(in: self) {
        for (offset, character) in string.utf16.enumerated() where Unicode.Scalar(character)?.properties.isWhitespace == true {
          guard let segmentLocation = textLayoutManager.location(textLineTextRange.location, offsetBy: offset),
                let segmentEndLocation = textLayoutManager.location(textLineTextRange.location, offsetBy: offset),
                let segmentRange = NSTextRange(location: segmentLocation, end: segmentEndLocation),
                let segmentFrame = textLayoutManager.textSegmentFrame(in: segmentRange, type: .standard),
                let font = lineFragment.attributedString.attribute(.font, at: offset, effectiveRange: nil) as? NSFont
          else {
            // assertionFailure()
            continue
          }
          
          let symbol: Character = switch character {
            case 0x0020: "\u{00B7}"  // • Space
            case 0x0009: "\u{00BB}"  // » Tab
            case 0x000A: "\u{00AC}"  // ¬ Line Feed
            case 0x000D: "\u{21A9}"  // ↩ Carriage Return
            case 0x00A0: "\u{235F}"  // ⎵ Non-Breaking Space
            case 0x200B: "\u{205F}"  // ⸱ Zero Width Space
            case 0x200C: "\u{200C}"  // ‌ Zero Width Non-Joiner
            case 0x200D: "\u{200D}"  // ‍ Zero Width Joiner
            case 0x2060: "\u{205F}"  //   Word Joiner
            case 0x2028: "\u{23CE}"  // ⏎ Line Separator
            case 0x2029: "\u{00B6}"  // ¶ Paragraph Separator
            default: "\u{00B7}"  // • Default symbol for unspecified whitespace
          }
          
          let symbolString = String(symbol)
          let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.placeholderTextColor
          ]
          
          let frameRect = CGRect(origin: CGPoint(x: segmentFrame.origin.x - layoutFragmentFrame.origin.x, y: segmentFrame.origin.y - layoutFragmentFrame.origin.y), size: CGSize(width: segmentFrame.size.width, height: segmentFrame.size.height)).pixelAligned
          
          let charSize = symbolString.size(withAttributes: attributes)
          let writingDirection = textLayoutManager.baseWritingDirection(at: textLineTextRange.location)
          let point = CGPoint(x: frameRect.origin.x - (writingDirection == .leftToRight ? 0 : charSize.width),
                              y: (frameRect.height - charSize.height) / 2)
          
          symbolString.draw(at: point, withAttributes: attributes)
        }
      }
    }
    
    context.restoreGState()
  }
}
