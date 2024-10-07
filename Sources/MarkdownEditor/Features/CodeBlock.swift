//
//  CodeBlock.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import AppKit


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
    
    let path = NSBezierPath()
    
//    let path = NSBezierPath(
//      roundedRect: NSRect(
//        origin: renderingSurfaceBounds.origin,
//        size: CGSize(
//          width: 100,
////          width: viewWidth,
//          height: renderingSurfaceBounds.height)
//      ),
//      xRadius: cornerRadius,
//      yRadius: cornerRadius
//    )
//    
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



extension MarkdownTextView {
  
  func drawRoundedRect(
    around range: NSRange,
    cornerRadius: CGFloat = 5.0,
    lineWidth: CGFloat = 2.0,
    color: NSColor = .red
  ) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let nsTextRange = NSTextRange(range, scopeRange: tcm.documentRange, provider: tcm)
    else {
      print("Issue with one of the above, bummer")
      return
    }
    
    print("Let's try and draw a rect around a range. Range: \(range)")
    
    // Create a path for the rounded rectangle
    let path = NSBezierPath()
    var isFirstRect = true
    var lastRect: NSRect?
    
    
    // Enumerate through the text segments in the range
    tlm.enumerateTextSegments(
      in: nsTextRange,
      type: .standard,
      options: []
    ) { (range, segmentFrame, baselinePosition, textContainer) in
      var rect = segmentFrame
      
      // Convert rect to view coordinates
      rect = self.convert(rect, from: nil)
      
      // Adjust rect to account for line width
      rect = rect.insetBy(dx: -lineWidth / 2, dy: -lineWidth / 2)
      
      if isFirstRect {
        path.move(to: NSPoint(x: rect.minX, y: rect.minY + cornerRadius))
        isFirstRect = false
      }
      
      // Draw rounded corners for top-left and top-right of first rectangle
      if lastRect == nil {
        path.line(to: NSPoint(x: rect.minX, y: rect.maxY - cornerRadius))
        path.appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 180,
                       endAngle: 90,
                       clockwise: true)
        
        path.line(to: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        path.appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 90,
                       endAngle: 0,
                       clockwise: true)
      } else {
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
      }
      
      path.line(to: NSPoint(x: rect.maxX, y: rect.minY))
      
      lastRect = rect
      return true
    }
    
    // Draw rounded corners for bottom-right and bottom-left of last rectangle
    if let lastRect = lastRect {
      path.line(to: NSPoint(x: lastRect.maxX, y: lastRect.minY + cornerRadius))
      path.appendArc(withCenter: NSPoint(x: lastRect.maxX - cornerRadius, y: lastRect.minY + cornerRadius),
                     radius: cornerRadius,
                     startAngle: 0,
                     endAngle: -90,
                     clockwise: true)
      
      path.line(to: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY))
      path.appendArc(withCenter: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY + cornerRadius),
                     radius: cornerRadius,
                     startAngle: -90,
                     endAngle: 180,
                     clockwise: true)
    }
    
    path.close()
    
    // Set the drawing attributes
    color.setStroke()
    path.lineWidth = lineWidth
    
    // Draw the path
    path.stroke()
  }
}

/// Usage: `textView.addRoundedRectHighlight(around: range)`
///
class TextHighlightView: NSView {
  var highlightPath: NSBezierPath?
  var highlightColor: NSColor = .red
  var lineWidth: CGFloat = 2.0
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let path = highlightPath else { return }
    
    highlightColor.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
  }
}

extension MarkdownTextView {
  
  func addRoundedRectHighlight(
    around range: NSRange,
    cornerRadius: CGFloat = 5.0,
    lineWidth: CGFloat = 2.0,
    color: NSColor = .red
  ) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let nsTextRange = NSTextRange(range, scopeRange: tcm.documentRange, provider: tcm)
    else {
      print("Issue with one of the above, bummer")
      return
    }
    
    let path = NSBezierPath()
    //    var isFirstRect = true
    //    var lastRect: NSRect?
    
    tlm.enumerateTextSegments(
      in: nsTextRange,
      type: .standard,
      options: []
    ) { (range, segmentFrame, baselinePosition, textContainer) in
      
      var rect = segmentFrame
      
      print(
        """
        Let's figure out where these coordinates are.
        
        This is the `segmentFrame`: \(segmentFrame)
        
        
        """
      )
      
      // Convert rect to view coordinates
      //      rect = self.convert(rect, from: nil)
      
      // Adjust rect to account for line width
      rect = rect.insetBy(dx: -lineWidth / 2, dy: -lineWidth / 2)
      
      //      if isFirstRect {
      //        isFirstRect = false
      //      }
      path.move(to: NSPoint(x: rect.minX, y: rect.minY + cornerRadius))
      
      // Draw rounded corners for top-left and top-right of first rectangle
      //      if lastRect == nil {
      path.line(to: NSPoint(x: rect.minX, y: rect.maxY - cornerRadius))
      path.appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                     radius: cornerRadius,
                     startAngle: 180,
                     endAngle: 90,
                     clockwise: true)
      
      path.line(to: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
      path.appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                     radius: cornerRadius,
                     startAngle: 90,
                     endAngle: 0,
                     clockwise: true)
      //      } else {
      //        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
      //      }
      
      path.line(to: NSPoint(x: rect.maxX, y: rect.minY))
      
      //      lastRect = rect
      return true
    }
    
    // Draw rounded corners for bottom-right and bottom-left of last rectangle
    //    if let lastRect = lastRect {
    //      path.line(to: NSPoint(x: lastRect.maxX, y: lastRect.minY + cornerRadius))
    //      path.appendArc(withCenter: NSPoint(x: lastRect.maxX - cornerRadius, y: lastRect.minY + cornerRadius),
    //                     radius: cornerRadius,
    //                     startAngle: 0,
    //                     endAngle: -90,
    //                     clockwise: true)
    
    //      path.line(to: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY))
    //      path.appendArc(withCenter: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY + cornerRadius),
    //                     radius: cornerRadius,
    //                     startAngle: -90,
    //                     endAngle: 180,
    //                     clockwise: true)
    //    }
    
    path.close()
    
    // Create and configure the highlight view
    let highlightView = TextHighlightView(frame: self.bounds)
    highlightView.highlightPath = path
    highlightView.highlightColor = color
    highlightView.lineWidth = lineWidth
    highlightView.autoresizingMask = [.width, .height]
    highlightView.wantsLayer = true
    highlightView.layer?.zPosition = 1
    
    // Add the highlight view as a subview
    //    self.addSubview(highlightView)
    
    self.addSubview(highlightView, positioned: .above, relativeTo: nil)
    // Ensure the highlight view is below the text
    //    self.sendSubviewToBack(highlightView)
  }
}




/// Usage: `textView.highlightTextRange(range)`

class HighlightTextAttachment: NSTextAttachment {
  var highlightColor: NSColor
  var cornerRadius: CGFloat
  
  init(color: NSColor, cornerRadius: CGFloat) {
    self.highlightColor = color
    self.cornerRadius = cornerRadius
    super.init(data: nil, ofType: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func image(
    forBounds imageBounds: CGRect,
    textContainer: NSTextContainer?,
    characterIndex charIndex: Int
  ) -> NSImage? {
    let image = NSImage(size: imageBounds.size)
    image.lockFocus()
    
    let bezierPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: imageBounds.size), xRadius: cornerRadius, yRadius: cornerRadius)
    highlightColor.setFill()
    bezierPath.fill()
    
    image.unlockFocus()
    return image
  }
}

extension MarkdownTextView {
  
  func highlightTextRange(
    _ range: NSRange,
    color: NSColor = .yellow.withAlphaComponent(0.3),
    cornerRadius: CGFloat = 3
  ) {
    
    guard let textStorage = textStorage else {
      print("No text storage")
      return
    }
    
    let attachment = HighlightTextAttachment(color: color, cornerRadius: cornerRadius)
    let attachmentChar = NSAttributedString(attachment: attachment)
    
    textStorage.beginEditing()
    
    // Get the rect for the range
    let rangeRect = firstRect(forCharacterRange: range, actualRange: nil)
    
    // Set the size of the attachment to match the text range
    attachment.bounds = CGRect(origin: .zero, size: rangeRect.size)
    
    // Insert the attachment at the start of the range
    textStorage.insert(attachmentChar, at: range.location)
    
    // Extend the original range to include the attachment
    let extendedRange = NSRange(location: range.location, length: range.length + 1)
    
    // Set the baseline offset to position the highlight correctly
    textStorage.addAttribute(.baselineOffset, value: NSNumber(value: -1), range: NSRange(location: range.location, length: 1))
    
    // Ensure the attachment doesn't displace text
    textStorage.addAttribute(.expansion, value: NSNumber(value: -1), range: NSRange(location: range.location, length: 1))
    
    textStorage.endEditing()
  }
}
