//
//  Untitled.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/2/2025.
//

import AppKit
import Highlightr

class MarkdownTextStorage: NSTextStorage {
  
  private let backingStore = NSMutableAttributedString()
  private let highlightr = Highlightr()!
  private let codeStorage = CodeAttributedString()
  
  override var string: String {
    return backingStore.string
  }
  
  override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
    return backingStore.attributes(at: location, effectiveRange: range)
  }
  
  override func replaceCharacters(in range: NSRange, with str: String) {
    beginEditing()
    backingStore.replaceCharacters(in: range, with: str)
    edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    endEditing()
  }
  
  override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(.editedAttributes, range: range, changeInLength: 0)
    endEditing()
  }
  
  override func processEditing() {
    super.processEditing()
    
    // Parse the text and apply Markdown styling
    applyMarkdownStyles()
    
    // Detect and highlight code blocks
    highlightCodeBlocks()
  }
  
  private func applyMarkdownStyles() {
    // Apply your Markdown styling logic here
    // (e.g., headings, bold, italic, etc.)
  }
  
  private func highlightCodeBlocks() {
    let text = backingStore.string
    let codeBlockPattern = "```(?:\\s*\\w+)?\n?([\\s\\S]*?)```"
    let regex = try! NSRegularExpression(pattern: codeBlockPattern, options: [])
    
    regex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
      guard let matchRange = match?.range(at: 1) else { return }
      
      /// Extract the code block content and language hint
      let codeBlock = (text as NSString).substring(with: matchRange)
      let languageHint = (text as NSString).substring(with: match!.range(at: 0))
        .components(separatedBy: .newlines).first?
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespaces)
      
      /// Highlight the code block using Highlightr
      if let highlightedCode = highlightr.highlight(codeBlock, as: languageHint) {
        backingStore.replaceCharacters(in: matchRange, with: highlightedCode)
      }
    }
  }
}
