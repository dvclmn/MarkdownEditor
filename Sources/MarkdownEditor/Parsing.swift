//
//  Parsing.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 12/8/2024.
//

import SwiftUI


public struct MarkdownFragment {
  let syntax: MarkdownSyntax
  let range: NSRange
  let content: String?  // Optional, as some elements (like horizontal rules) might not have content
}

public class MarkdownParser {
  var elements: [MarkdownFragment] = []
  var visibleElements: [MarkdownFragment] = []
  
  public var text: String {
    didSet {
      updateElements()
    }
  }
  
  public var visibleRange: NSRange {
    didSet {
      updateVisibleElements()
    }
  }
  
  init(text: String = "") {
    self.text = text
    self.visibleRange = NSRange(location: 0, length: 0)
    updateElements()
  }
  
  private func updateElements() {
    // Parse the entire text and update the elements array
    // This would involve your Markdown parsing logic
  }
  
  private func updateVisibleElements() {
    visibleElements = elements.filter { NSIntersectionRange($0.range, visibleRange).length > 0 }
  }
  
  public func elementsInRange(_ range: NSRange) -> [MarkdownFragment] {
    return elements.filter { NSIntersectionRange($0.range, range).length > 0 }
  }
  
  public func elementAt(_ location: Int) -> MarkdownFragment? {
    return elements.first { NSLocationInRange(location, $0.range) }
  }
  
  public func applyStyle(for element: MarkdownFragment) -> [NSAttributedString.Key: Any] {
    // Return appropriate style attributes based on the element
    
    return [:]
  }
  
  public func toggleSyntax(_ syntax: MarkdownSyntax, in range: NSRange) {
    // Logic to add or remove syntax in the given range
  }
}

