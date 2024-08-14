//
//  NSTextStorageDelegate.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI

class MarkdownStorageDelegate: NSObject, NSTextStorageDelegate {
  
}


extension MarkdownTextView: NSTextContentStorageDelegate {
  
  
  public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
    guard let attributedString = textContentStorage.attributedString else { return nil }
    
    let paragraphString = attributedString.attributedSubstring(from: range)
    let inlineCodeRanges = findInlineCodeRanges(in: paragraphString)
    
    if !inlineCodeRanges.isEmpty {
      let textRange = textContentStorage.textRange(for: range)
      return MarkdownParagraph(attributedString: paragraphString, textContentManager: textContentStorage, elementRange: textRange, inlineCodeRanges: inlineCodeRanges)
    }
    
    return nil
  }
  
  private func findInlineCodeRanges(in attributedString: NSAttributedString) -> [NSRange] {
    let fullRange = NSRange(location: 0, length: attributedString.length)
    let regex = try! NSRegularExpression(pattern: "`[^`\n]+`")
    let matches = regex.matches(in: attributedString.string, options: [], range: fullRange)
    return matches.map { $0.range }
  }
}
