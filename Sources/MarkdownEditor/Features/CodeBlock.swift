//
//  CodeBlock.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import AppKit
//
//
//class CodeBlockBackground: NSTextLayoutFragment {
//  
//  let backgroundColor: NSColor = .lightGray.withAlphaComponent(0.2)
//  let cornerRadius: CGFloat = 5
//  let viewWidth: CGFloat
//  var isActive: Bool
//  
//  init(
//    textElement: NSTextElement,
//    range rangeInElement: NSTextRange?,
//    viewWidth: CGFloat,
//    isActive: Bool = false
//  ) {
//    self.viewWidth = viewWidth
//    self.isActive = isActive
//    super.init(textElement: textElement, range: rangeInElement)
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("Don't use this init")
//  }
//  
//  override func draw(at point: CGPoint, in context: CGContext) {
//    
//    context.saveGState()
//    
//    let colour = isActive ? NSColor.blue.withAlphaComponent(0.4) : backgroundColor
//    
//    let path = NSBezierPath()
//    
//    //    let path = NSBezierPath(
//    //      roundedRect: NSRect(
//    //        origin: renderingSurfaceBounds.origin,
//    //        size: CGSize(
//    //          width: 100,
//    ////          width: viewWidth,
//    //          height: renderingSurfaceBounds.height)
//    //      ),
//    //      xRadius: cornerRadius,
//    //      yRadius: cornerRadius
//    //    )
//    //
//    path.move(to: point)
//    
//    path.line(to: point.shiftRight(20))
//    
//    path.curve(to: point.shift(dx: 40, dy: 80), controlPoint: point.shiftRight(viewWidth))
//    
//    path.close()
//    
//    colour.setFill()
//    path.fill()
//    
//    context.strokePath()
//    context.restoreGState()
//    
//    // Draw the actual text content
//    super.draw(at: point, in: context)
//  }
//  
//}
//


extension MarkdownTextView {
  
  /// Usage: `textView.highlightTextRange(range)`
  
//  class HighlightTextAttachment: NSTextAttachment {
//    var highlightColor: NSColor
//    var cornerRadius: CGFloat
//    
//    init(color: NSColor, cornerRadius: CGFloat) {
//      self.highlightColor = color
//      self.cornerRadius = cornerRadius
//      super.init(data: nil, ofType: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func image(
//      forBounds imageBounds: CGRect,
//      textContainer: NSTextContainer?,
//      characterIndex charIndex: Int
//    ) -> NSImage? {
//      let image = NSImage(size: imageBounds.size)
//      image.lockFocus()
//      
//      let bezierPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: imageBounds.size), xRadius: cornerRadius, yRadius: cornerRadius)
//      highlightColor.setFill()
//      bezierPath.fill()
//      
//      image.unlockFocus()
//      return image
//    }
//  }
//  
  
//  
//  func highlightTextRange(
//    _ range: NSRange,
//    color: NSColor = .yellow.withAlphaComponent(0.3),
//    cornerRadius: CGFloat = 3
//  ) {
//    
//    guard let textStorage = textStorage else {
//      print("No text storage")
//      return
//    }
//    
//    let attachment = HighlightTextAttachment(color: color, cornerRadius: cornerRadius)
//    let attachmentChar = NSAttributedString(attachment: attachment)
//    
//    textStorage.beginEditing()
//    
//    // Get the rect for the range
//    let rangeRect = firstRect(forCharacterRange: range, actualRange: nil)
//    
//    // Set the size of the attachment to match the text range
//    attachment.bounds = CGRect(origin: .zero, size: rangeRect.size)
//    
//    // Insert the attachment at the start of the range
//    textStorage.insert(attachmentChar, at: range.location)
//    
//    // Extend the original range to include the attachment
//    let extendedRange = NSRange(location: range.location, length: range.length + 1)
//    
//    // Set the baseline offset to position the highlight correctly
//    textStorage.addAttribute(.baselineOffset, value: NSNumber(value: -1), range: NSRange(location: range.location, length: 1))
//    
//    // Ensure the attachment doesn't displace text
//    textStorage.addAttribute(.expansion, value: NSNumber(value: -1), range: NSRange(location: range.location, length: 1))
//    
//    textStorage.endEditing()
//  }
}
