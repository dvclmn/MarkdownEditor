//
//  ContentManager.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit


class MarkdownContentManager: NSTextContentManager {
  
  private var markdownElements: [MarkdownElement] = []
  
  override func replaceContents(in range: NSTextRange, with text: NSTextContentManager.TextElements) throws {
    try super.replaceContents(in: range, with: text)
    parseMarkdown()
  }
  
  private func parseMarkdown() {
    guard let fullRange = textStorage?.fullRange else { return }
    
    // Clear existing elements
    markdownElements.removeAll()
    
    // Implement your Markdown parsing logic here
    // This is a simplified example
    textStorage?.enumerateAttribute(.paragraphStyle, in: fullRange) { style, range, _ in
      if let paragraphStyle = style as? NSParagraphStyle {
        if paragraphStyle.headIndent > 0 {
          markdownElements.append(MarkdownElement(type: .codeBlock, range: range))
        } else if paragraphStyle.firstLineHeadIndent > 0 {
          markdownElements.append(MarkdownElement(type: .blockQuote, range: range))
        } else {
          markdownElements.append(MarkdownElement(type: .paragraph, range: range))
        }
      }
    }
    
    // Notify that the content has changed
    enumerateTextElements(in: fullRange) { _, _ in true }
  }
  
  override func enumerateTextElements(from location: NSTextLocation, options: NSTextContentManager.EnumerationOptions = [], using block: (NSTextElement, UnsafeMutablePointer<ObjCBool>) -> Void) {
    for element in markdownElements {
      var stop = ObjCBool(false)
      block(element, &stop)
      if stop.boolValue { break }
    }
  }
}
