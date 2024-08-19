//
//  AttributedString.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

public typealias Attributes = [NSAttributedString.Key: Any]


public struct AttributeSet: ExpressibleByDictionaryLiteral, Sendable {
  nonisolated(unsafe) public var attributes: Attributes
  
  public init(dictionaryLiteral elements: (Attributes.Key, Attributes.Value)...) {
    self.attributes = Dictionary(uniqueKeysWithValues: elements)
  }
}

extension AttributeSet: Sequence {
  public func makeIterator() -> Dictionary<NSAttributedString.Key, Any>.Iterator {
    return attributes.makeIterator()
  }
}

extension AttributeSet {
  
  
  init(_ attributes: [NSAttributedString.Key: Any]) {
    self.attributes = attributes
  }
  
  subscript(_ key: NSAttributedString.Key) -> Any? {
    get { attributes[key] }
    set { attributes[key] = newValue }
  }
  
  
}


public extension AttributeSet {
  
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

public extension NSMutableAttributedString {
  
  @MainActor func setAttributesCustom(
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

