//
//  EditAttributes.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import STTextKitPlus

extension MarkdownView {
  
  /// Add attribute. Need `needsViewportLayout = true` to reflect changes.
  func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange, updateLayout: Bool = true) {
    guard let textRange = NSTextRange(range, in: textContentManager) else {
      preconditionFailure("Invalid range \(range)")
    }
    
    addAttributes(attrs, range: textRange, updateLayout: updateLayout)
  }
  
  /// Add attribute. Need `needsViewportLayout = true` to reflect changes.
  func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSTextRange, updateLayout: Bool = true) {
    
    textContentManager.performEditingTransaction {
      (textContentManager as? NSTextContentStorage)?.textStorage?.addAttributes(attrs, range: NSRange(range, in: textContentManager))
    }
    
    if updateLayout {
      updateTypingAttributes()
      needsLayout = true
    }
  }
  
  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange, updateLayout: Bool = true) {
    guard let textRange = NSTextRange(range, in: textContentManager) else {
      preconditionFailure("Invalid range \(range)")
    }
    
    setAttributes(attrs, range: textRange, updateLayout: updateLayout)
  }
  
  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSTextRange, updateLayout: Bool = true) {
    
    textContentManager.performEditingTransaction {
      (textContentManager as? NSTextContentStorage)?.textStorage?.setAttributes(attrs, range: NSRange(range, in: textContentManager))
    }
    
    
    if updateLayout {
      updateTypingAttributes()
      needsLayout = true
    }
  }
  
  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  func removeAttribute(_ attribute: NSAttributedString.Key, range: NSRange, updateLayout: Bool = true) {
    guard let textRange = NSTextRange(range, in: textContentManager) else {
      preconditionFailure("Invalid range \(range)")
    }
    
    removeAttribute(attribute, range: textRange, updateLayout: updateLayout)
  }
  
  /// Set attributes. Need `needsViewportLayout = true` to reflect changes.
  func removeAttribute(_ attribute: NSAttributedString.Key, range: NSTextRange, updateLayout: Bool = true) {
    
    textContentManager.performEditingTransaction {
      (textContentManager as? NSTextContentStorage)?.textStorage?.removeAttribute(attribute, range: NSRange(range, in: textContentManager))
    }
    
    updateTypingAttributes()
    
    if updateLayout {
      needsLayout = true
    }
  }
  
  
  func updateTypingAttributes(at location: NSTextLocation? = nil) {
    if let location {
      textView.typingAttributes = typingAttributes(at: location)
    } else {
      // TODO: doesn't work work correctly (at all) for multiple insertion points where each has different typing attribute
      if let insertionPointSelection = textLayoutManager.insertionPointSelections.first,
         let startLocation = insertionPointSelection.textRanges.first?.location
      {
        textView.typingAttributes = typingAttributes(at: startLocation)
      }
    }
  }
  
  func typingAttributes(at startLocation: NSTextLocation) -> [NSAttributedString.Key : Any] {
    guard !textLayoutManager.documentRange.isEmpty else {
      return textView.typingAttributes
    }
    
    var attrs: [NSAttributedString.Key: Any] = [:]
    // The attribute is derived from the previous (upstream) location,
    // except for the beginning of the document where it from whatever is at location 0
    let options: NSTextContentManager.EnumerationOptions = startLocation == textLayoutManager.documentRange.location ? [] : [.reverse]
    let offsetDiff = startLocation == textLayoutManager.documentRange.location ? 0 : -1
    
    textContentManager.enumerateTextElements(from: startLocation, options: options) { textElement in
      if let attributedTextElement = textElement as? AttributedTextElement,
         let elementRange = textElement.elementRange,
         let textContentManager = textElement.textContentManager
      {
        let offset = textContentManager.offset(from: elementRange.location, to: startLocation)
        assert(offset != NSNotFound, "Unexpected location")
        attrs = attributedTextElement.attributedString.attributes(at: offset + offsetDiff, effectiveRange: nil)
      }
      
      return false
    }
    
    // fill in with missing typing attributes if needed
    attrs.merge(self.defaultTypingAttributes, uniquingKeysWith: { current, _ in current})
    return attrs
  }
  
}


protocol AttributedTextElement: NSTextElement {
  var attributedString: NSAttributedString { get }
}
