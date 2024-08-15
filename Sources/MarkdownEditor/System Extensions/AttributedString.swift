//
//  AttributedString.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

@MainActor
struct AttributeSet: @preconcurrency ExpressibleByDictionaryLiteral {
  
  let attributes: [NSAttributedString.Key: Any]
  
  init(
    dictionaryLiteral elements: (NSAttributedString.Key, Any)...
  ) {
    self.attributes = Dictionary(uniqueKeysWithValues: elements)
  }
  
}

extension AttributeSet {
  
  static let highlighter: AttributeSet = [
    .foregroundColor: NSColor.yellow
  ]
  
  static let codeBlock: AttributeSet = [
    .foregroundColor: NSColor.white,
    .backgroundColor: NSColor.darkGray,
    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
  ]
  
}

extension NSMutableAttributedString {
  @MainActor func addAttributes(_ attributeSet: AttributeSet, range: NSRange) {
    addAttributes(attributeSet.attributes, range: range)
  }
}

