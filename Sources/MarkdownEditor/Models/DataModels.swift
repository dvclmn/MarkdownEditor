//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

public enum Language: String, CaseIterable {
  case swift
  case python
  case rust
  case go
}

public struct EditorConfiguration: Sendable, Equatable {
  var isShowingFrames: Bool
  var insets: CGFloat
  
  public init(
    isShowingFrames: Bool = false,
    insets: CGFloat = 20
  ) {
    self.isShowingFrames = isShowingFrames
    self.insets = insets
  }
}

class MarkdownBlock: NSTextElement {
  var range: NSTextRange
  let syntax: Markdown.Syntax
  var languageIdentifier: Language?
  
  init(
    _ textContentManager: NSTextContentManager,
    range: NSTextRange,
    syntax: Markdown.Syntax,
    languageIdentifier: Language? = nil
  ) {
    self.range = range
    self.syntax = syntax
    self.languageIdentifier = languageIdentifier
    super.init(textContentManager: textContentManager)
  }
}

public struct Markdown {
  public enum LayoutType {
    case block
    case line
    case inline
  }
  
  public enum Boundary {
    case opening
    case closing
    case single // For syntax that doesn't have separate opening and closing (like horizontal rules)
  }
  
}

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

