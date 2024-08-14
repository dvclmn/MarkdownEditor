//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/8/2024.
//

import SwiftUI


class MarkdownParagraph: NSTextParagraph {
  var inlineCodeRanges: [NSRange]
  
  init(
    attributedString: NSAttributedString,
    textContentManager: NSTextContentManager,
    elementRange: NSTextRange?,
    inlineCodeRanges: [NSRange]
  ) {
    self.inlineCodeRanges = inlineCodeRanges
    super.init(attributedString: attributedString)
    self.textContentManager = textContentManager
    self.elementRange = elementRange
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class InlineCodeLayoutFragment: NSTextLayoutFragment {
  override func draw(at point: CGPoint, in context: CGContext) {
    super.draw(at: point, in: context)
    
    guard let paragraph = textElement as? MarkdownParagraph else { return }
    
    context.saveGState()
    context.setFillColor(NSColor.systemGray.withAlphaComponent(0.2).cgColor)
    
    for range in paragraph.inlineCodeRanges {
//      let glyphRange = textLayoutManager?.glyphRange(for: range)
//      if let rect = textLayoutManager?.boundingRect(for: glyphRange!) {
//        let adjustedRect = CGRect(x: rect.minX + point.x, y: rect.minY + point.y, width: rect.width, height: rect.height)
//        context.fill(adjustedRect)
//      }
    }
    
    context.restoreGState()
  }
}

public struct MarkdownFragment {
  let syntax: Markdown.Syntax
  let range: NSTextRange
  let content: String?  // Optional, as some elements (like horizontal rules) might not have content
}

//public class MarkdownParser {
//  var elements: [MarkdownFragment] = []
//  var visibleElements: [MarkdownFragment] = []
//  
//  public var text: String {
//    didSet {
//      updateElements()
//    }
//  }
  
//  public var visibleRange: NSRange {
//    didSet {
//      updateVisibleElements()
//    }
//  }
//  
//  init(text: String = "") {
//    self.text = text
//    self.visibleRange = NSRange(location: 0, length: 0)
//    updateElements()
//  }
  
//  private func updateElements() {
    // Parse the entire text and update the elements array
    // This would involve your Markdown parsing logic
//  }
  
//  private func updateVisibleElements() {
//    visibleElements = elements.filter { NSIntersectionRange($0.range, visibleRange).length > 0 }
//  }
//  
//  public func elementsInRange(_ range: NSRange) -> [MarkdownFragment] {
//    return elements.filter { NSIntersectionRange($0.range, range).length > 0 }
//  }
//  
//  public func elementAt(_ location: Int) -> MarkdownFragment? {
//    return elements.first { NSLocationInRange(location, $0.range) }
//  }
  
//  public func applyStyle(for element: MarkdownFragment) -> [NSAttributedString.Key: Any] {
//    // Return appropriate style attributes based on the element
//    
//    return [:]
//  }
//  
//  public func toggleSyntax(_ syntax: Markdown.Syntax, in range: NSRange) {
//    // Logic to add or remove syntax in the given range
//  }
//}

