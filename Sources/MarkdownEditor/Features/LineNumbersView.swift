//
//  LineNumberView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit
import BaseHelpers
import STTextKitPlus
import TextCore

class LineNumberView: NSRulerView {
  
  weak var textView: MarkdownTextView? {
    return clientView as? MarkdownTextView
  }
  
  override init(scrollView: NSScrollView?, orientation: NSRulerView.Orientation) {
    super.init(scrollView: scrollView, orientation: orientation)
    self.clientView = scrollView?.documentView as? MarkdownTextView
    self.ruleThickness = 30
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawHashMarksAndLabels(in rect: NSRect) {
    guard let textView = textView,
          let tlm = textView.textLayoutManager
            //          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return }
    
    let visibleRect = textView.visibleRect
    
    let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)

    let attributes: Attributes = [
      .font: font as Any,
      .foregroundColor: NSColor.secondaryLabelColor
    ]
    
    var lineNumber = 1
    var lastYPosition: CGFloat = -1
    
    
    tlm.enumerateTextLayoutFragments(in: tlm.documentRange, options: .ensuresLayout) { layoutFragment in
      for (index, lineFragment) in layoutFragment.textLineFragments.enumerated() {
        let lineRect = lineFragment.typographicBounds
        let yPosition = lineRect.minY + layoutFragment.layoutFragmentFrame.minY - visibleRect.minY
        
        // Only draw if this is a new Y position
        guard yPosition > lastYPosition else { continue }
        
        let isNewParagraph: Bool
        
        if index == 0 {
          // This is the first line, so it's likely a new paragraph
          isNewParagraph = false
        } else if let textElement = layoutFragment.textElement as? NSTextParagraph,
                  let elementRange = textElement.elementRange?.location {
          // Check if this layout fragment starts a new paragraph
          isNewParagraph = elementRange == layoutFragment.rangeInElement.location
        } else {
          // If we can't determine, assume it's not a new paragraph
          isNewParagraph = false
        }
        
        let lineNumberString: String
        if isNewParagraph {
          lineNumberString = "\(lineNumber)"
          lineNumber += 1
        } else {
          lineNumberString = "•" // or any other symbol for continuation
        }
        
        let size = lineNumberString.size(withAttributes: attributes)
        let xPosition = self.bounds.width - size.width - 4
        
        lineNumberString.draw(at: NSPoint(x: xPosition, y: yPosition), withAttributes: attributes)
        
        lastYPosition = yPosition
      }
      return true
    }

    
    
//
//    
//    tlm.enumerateTextLayoutFragments(in: tlm.documentRange, options: .ensuresLayout) { layoutFragment in
//      for lineFragment in layoutFragment.textLineFragments {
//        let lineRect = lineFragment.typographicBounds
//        let yPosition = lineRect.minY + layoutFragment.layoutFragmentFrame.minY - visibleRect.minY
//        
//        // Only draw if this is a new Y position
//        if yPosition > lastYPosition {
//          let lineNumberString = "\(lineNumber)"
//          let size = lineNumberString.size(withAttributes: attributes)
//          let xPosition = self.bounds.width - size.width - 4
//          
//          lineNumberString.draw(at: NSPoint(x: xPosition, y: yPosition), withAttributes: attributes)
//          
//          lineNumber += 1
//          lastYPosition = yPosition
//        }
//      }
//      return true
//    }
    
    
    
    //    tlm.enumerateTextLayoutFragments(in: viewportRange, options: .ensuresLayout) { layoutFragment in
    //      for lineFragment in layoutFragment.textLineFragments {
    //        let lineRect = lineFragment.typographicBounds
    //        let yPosition = lineRect.minY + layoutFragment.layoutFragmentFrame.minY - visibleRect.minY
    //
    //        // Only draw if this is a new Y position
    //        if yPosition > lastYPosition {
    //          let lineNumberString = "\(lineNumber)"
    //          let size = lineNumberString.size(withAttributes: attributes)
    //          let xPosition = self.bounds.width - size.width - 4
    //
    //          lineNumberString.draw(at: NSPoint(x: xPosition, y: yPosition), withAttributes: attributes)
    //
    //          lineNumber += 1
    //          lastYPosition = yPosition
    //        }
    //      }
    //      return true
    //    }
  }
  
  
  
  override func mouseDown(with event: NSEvent) {
    selectLines(at: event.locationInWindow, with: event)
  }
  
  override func mouseDragged(with event: NSEvent) {
    selectLines(at: event.locationInWindow, with: event)
  }
  
  
  private func selectLines(at point: NSPoint, with event: NSEvent) {
    guard let textView = textView,
          let tlm = textView.textLayoutManager,
          let visibleRange = tlm.textViewportLayoutController.viewportRange,
          let tcm = tlm.textContentManager
    else { return }
    
    let localPoint = convert(point, from: nil)
    
    // Find the text location corresponding to the click point
    
    
    
    guard let location = tlm.location(interactingAt: localPoint, inContainerAt: visibleRange.location) else { return }
    
    let fragment = tlm.textLineFragment(at: location)
    
    
    
    // Get the line range for this location
    //    guard let lineRange = fragment.textRange(in: <#T##NSTextLayoutFragment#>) else {
    //      return
    //    }
    
    // Convert NSTextRange to NSRange for compatibility with existing String extensions
    //    if let startOffset = tcm.offset(from: <#T##any NSTextLocation#>, to: <#T##any NSTextLocation#>)
    
    //      .offset(from: tcm.documentRange.location, to: lineRange),
    //       let endOffset = tcm.offset(from: tcm.documentRange.location, to: lineRange.endLocation) {
    let nsRange = NSRange(location: 0, length: 100)
    //      let nsRange = NSRange(location: startOffset, length: endOffset - startOffset)
    
    if event.modifierFlags.contains(.shift) {
      let currentSelection = textView.selectedRange()
      let newSelection = NSUnionRange(currentSelection, nsRange)
      textView.setSelectedRange(newSelection)
    } else {
      textView.setSelectedRange(nsRange)
    }
    
  }
  
  //  private func selectLines(at point: NSPoint, with event: NSEvent) {
  //    guard let textView = textView,
  //          let tlm = textView.textLayoutManager,
  //          let textContainer = textView.textContainer else {
  //      return
  //    }
  //
  //    let localPoint = convert(point, from: nil)
  //
  //
  //    let glyphIndex = layoutManager.glyphIndex(for: localPoint, in: textContainer)
  //    let lineNumber = textView.string.lineNumber(for: glyphIndex)
  //
  //    let lineRange = textView.string.lineRange(for: lineNumber)
  //
  //    if event.modifierFlags.contains(.shift) {
  //      let currentSelection = textView.selectedRange()
  //      let newSelection = NSUnionRange(currentSelection, lineRange)
  //      textView.setSelectedRange(newSelection)
  //    } else {
  //      textView.setSelectedRange(lineRange)
  //    }
  //  }
  
}

extension NSString {
  func lineNumber(for characterIndex: Int) -> Int {
    let substring = self.substring(to: characterIndex)
    return substring.components(separatedBy: .newlines).count
  }
}


extension String {
  //
  //  func lineNumber(for characterIndex: Int) -> Int {
  //    let substring = self.substring(to: characterIndex)
  //    return substring.components(separatedBy: .newlines).count
  //  }
  //
  
  func lineRange(for lineNumber: Int) -> NSRange {
    let lines = components(separatedBy: .newlines)
    var charCount = 0
    
    for (index, line) in lines.enumerated() {
      if index + 1 == lineNumber {
        return NSRange(location: charCount, length: line.count)
      }
      charCount += line.count + 1 // +1 for newline character
    }
    
    return NSRange(location: 0, length: 0)
  }
}
