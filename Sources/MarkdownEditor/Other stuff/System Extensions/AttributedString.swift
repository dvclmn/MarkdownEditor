//
//  AttributedString.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

public typealias Attributes = [NSAttributedString.Key: Any]

@MainActor
struct AttributeSet: @preconcurrency ExpressibleByDictionaryLiteral {
  
  let attributes: Attributes
  
  init(
    dictionaryLiteral elements: (Attributes.Key, Attributes.Value)...
  ) {
    self.attributes = Dictionary(uniqueKeysWithValues: elements)
  }
  
}

extension AttributeSet {
  
  static let highlighter: AttributeSet = [
    .foregroundColor: NSColor.yellow,
    .backgroundColor: NSColor.orange.withAlphaComponent(0.6)
  ]
  
  static let codeBlock: AttributeSet = [
    .foregroundColor: NSColor.white,
    .backgroundColor: NSColor.darkGray,
    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
  ]
  
}

extension NSMutableAttributedString {
  @MainActor func setAttributesButts(
    _ attributeSet: AttributeSet,
    range: NSRange,
    with typingAttributes: Attributes? = nil
  ) {
    
    if let typingAttributes = typingAttributes {
      
//      setAttributes(attributeSet.attributes.merging(typingAttributes, uniquingKeysWith: { key, value in
//        
//      }), range: range)
      setAttributes(attributeSet.attributes, range: range)
      addAttributes(typingAttributes, range: range)
    } else {
      setAttributes(attributeSet.attributes, range: range)
    }
  }
}

