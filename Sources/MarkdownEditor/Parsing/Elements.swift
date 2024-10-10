//
//  Elements.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 2/9/2024.
//

import Foundation
import AppKit
import BaseHelpers
import TextCore
import Rearrange

public struct Markdown {
  
  public struct Element: Hashable, Sendable {
    var string: String
    var syntax: Markdown.Syntax
    var ranges: Markdown.Ranges
    
    
    /// These are really only for code block background, should
    /// probably split into a more dedicated type at some point.
    var originY: CGFloat?
    var rectHeight: CGFloat?
  }
}

public extension Markdown {
  
  struct Ranges: Sendable, Hashable {
    var all: NSRange
    var leading: NSRange
    var content: NSRange
    var trailing: NSRange
  }
  
}

public extension Markdown.Element {
  
  func getRect(
    with width: CGFloat,
    config: MarkdownEditorConfiguration
  ) -> NSRect? {
    
    guard let originY = self.originY, let height = self.rectHeight else { return nil }
    
    let insets: CGFloat = config.insets
    let padding: CGFloat = config.codeBlockPadding
    
    let originX: CGFloat = insets - padding
    let adjustedOriginY: CGFloat = originY - padding
    
    let adjustedWidth = width - (insets * 2) + (padding * 2)
    let adjustedHeight = height + (padding * 2)
    
    let rect = NSRect(
      origin: CGPoint(x: originX, y: adjustedOriginY),
      size: CGSize(width: adjustedWidth, height: adjustedHeight)
    )
    
    return rect
  }
  

  var summary: String {
    let result: String = """
    Preview: \(self.string.preview())
    Syntax: \(self.syntax.name)
    Range: \(self.ranges.all.info)
    """
    
    return result
  }
}

extension MarkdownTextView {
  var elementCount: Int {
    self.elements.count
  }
  
  var elementsSummary: String {
    let summarizedElements = self.elements.reduce(into: [:]) { counts, element in
      counts[element.syntax, default: 0] += 1
    }
    
    let summaryStrings = summarizedElements.map { syntax, count in
      "\(count)x \(syntax.name)"
    }
    
    let result = summaryStrings.sorted { $0 > $1 }.joined(separator: ", ")
    
    return result
  }
}

