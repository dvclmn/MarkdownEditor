////
////  ContentManager.swift
////  MarkdownEditor
////
////  Created by Dave Coleman on 17/8/2024.
////
//
//import AppKit
//
//class MarkdownContentStorage: NSTextContentStorage {
//  
//  enum MarkdownElementType {
//    case paragraph
//    case heading(level: Int)
//    case codeBlock
//    case blockQuote
//    // Add other Markdown element types as needed
//  }
//  
////  override func processEditing(for textStorage: NSTextStorage, edited editMask: NSTextStorageEditActions, range newCharRange: NSRange, changeInLength delta: Int, invalidatedRange invalidatedCharRange: NSRange) {
////    parseMarkdown(in: invalidatedCharRange)
////  }
////  
////  
////
//  
//
//  private func parseMarkdown(in range: NSTextRange) {
//    
//    enumerateTextElements(from: range.location) { element in
//      if let markdownElement = element as? MarkdownElement {
//        removeTextElement(markdownElement)
//      }
//      return true
//    }
//    
//    // Remove existing elements in the affected range
//    enumerateTextElements(in: NSTextRange(location: range.location, end: range.upperBound)!) { element, _, _ in
//      if let markdownElement = element as? MarkdownElement {
//        removeTextElement(markdownElement)
//      }
//      return true
//    }
//    
//    // Implement your Markdown parsing logic here
//    // This is a simplified example
//    attributedString.enumerateAttribute(.paragraphStyle, in: range, options: []) { style, elementRange, _ in
//      if let paragraphStyle = style as? NSParagraphStyle {
//        let element: MarkdownElement
//        if paragraphStyle.headIndent > 0 {
//          element = MarkdownElement(type: .codeBlock, range: elementRange)
//        } else if paragraphStyle.firstLineHeadIndent > 0 {
//          element = MarkdownElement(type: .blockQuote, range: elementRange)
//        } else {
//          element = MarkdownElement(type: .paragraph, range: elementRange)
//        }
//        addTextElement(element)
//      }
//    }
//  }
//}
