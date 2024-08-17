//
//  GutterView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

class GutterView: NSView {
  
  weak var textView: NSTextView?
  
  var lineNumbers: [Int] = [1, 2, 3]
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    //        guard let context = NSGraphicsContext.current?.cgContext else { return }
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: NSFont.systemFont(ofSize: 10),
      .foregroundColor: NSColor.secondaryLabelColor,
      .backgroundColor: NSColor.blue
    ]
    
    for (index, lineNumber) in lineNumbers.enumerated() {
      let y = CGFloat(index) * 14 // Adjust based on your line height
      let string = "\(lineNumber)"
      string.draw(at: CGPoint(x: bounds.width - 5, y: y), withAttributes: attributes)
    }
  }
}
