//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI

@MainActor
class BlockquoteLineAttachmentCell: NSTextAttachmentCell {
  let lineWidth: CGFloat = 2
  let lineColor: NSColor = .gray
  
  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
    guard let context = NSGraphicsContext.current?.cgContext else { return }
    
    context.setLineWidth(lineWidth)
    context.setStrokeColor(lineColor.cgColor)
    
    let startPoint = CGPoint(x: cellFrame.minX + 4, y: cellFrame.minY)
    let endPoint = CGPoint(x: cellFrame.minX + 4, y: cellFrame.maxY)
    
    context.move(to: startPoint)
    context.addLine(to: endPoint)
    context.strokePath()
  }
  
  override func cellSize() -> NSSize {
    return NSSize(width: 10, height: 0)  // Width of 10 to accommodate the line and some padding
  }
}

class CodeBlockBackgroundAttachmentCell: NSTextAttachmentCell {
  let backgroundColor: NSColor = .lightGray.withAlphaComponent(0.2)
  let cornerRadius: CGFloat = 5
  
  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
    let path = NSBezierPath(roundedRect: cellFrame, xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundColor.setFill()
    path.fill()
  }
  
  override func cellSize() -> NSSize {
    return .zero  // Size will be determined by the text it's attached to
  }
}


extension NSMutableAttributedString {
  @MainActor
  func addBlockquoteLine(to range: NSRange) {
    let attachment = NSTextAttachment()
    attachment.attachmentCell = BlockquoteLineAttachmentCell()
    let attachmentString = NSAttributedString(attachment: attachment)
    
    self.insert(attachmentString, at: range.location)
  }
  
  @MainActor
  func addCodeBlockBackground(to range: NSRange) {
    let attachment = NSTextAttachment()
    attachment.attachmentCell = CodeBlockBackgroundAttachmentCell()
    let attachmentString = NSAttributedString(attachment: attachment)
    
    self.insert(attachmentString, at: range.location)
    self.addAttribute(.paragraphStyle, value: CodeBlockBackgroundAttachmentCell(), range: range)
  }
}

