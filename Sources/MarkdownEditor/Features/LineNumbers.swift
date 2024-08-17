//
//  GutterView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit

extension NSString {
  func lineCount(in range: NSRange) -> Int {
    var lineCount = 0
    var index = range.location
    let end = range.location + range.length
    
    while index < end {
      lineCount += 1
      index = (self as NSString).lineRange(for: NSRange(location: index, length: 0)).upperBound
    }
    
    return lineCount
  }
}

class GutterView: NSView {
  
  weak var textView: NSTextView?
  
  var lineNumbers: [Int] = [1, 2, 3]
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let textView = textView,
          let layoutManager = textView.layoutManager,
          let textContainer = textView.textContainer else {
      return
    }
    
    let visibleRect = textView.visibleRect
    let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
    let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
    
    let text = textView.string as NSString
    let lineRange = text.lineRange(for: characterRange)
    
    let font = NSFont.systemFont(ofSize: 10)
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: NSColor.secondaryLabelColor
    ]
    
    let lineHeight = layoutManager.defaultLineHeight(for: font)
    
    for lineNumber in 1...text.lineCount(in: lineRange) {
      let lineRect = layoutManager.lineFragmentRect(forGlyphAt: layoutManager.glyphIndexForCharacter(at: lineRange.location + lineNumber - 1), effectiveRange: nil)
      
      let yPosition = lineRect.minY - visibleRect.minY
      let lineNumberString = "\(lineNumber)"
      
      let size = lineNumberString.size(withAttributes: attributes)
      let xPosition = bounds.width - size.width - 4
      
      lineNumberString.draw(at: NSPoint(x: xPosition, y: yPosition), withAttributes: attributes)
    }

//
//    //        guard let context = NSGraphicsContext.current?.cgContext else { return }
//    
//    let attributes: [NSAttributedString.Key: Any] = [
//      .font: NSFont.systemFont(ofSize: 10),
//      .foregroundColor: NSColor.secondaryLabelColor,
//      .backgroundColor: NSColor.blue
//    ]
//    
//    for (index, lineNumber) in lineNumbers.enumerated() {
//      let y = CGFloat(index) * 14 // Adjust based on your line height
//      let string = "\(lineNumber)"
//      string.draw(at: CGPoint(x: bounds.width - 5, y: y), withAttributes: attributes)
//    }
    
  }
}
