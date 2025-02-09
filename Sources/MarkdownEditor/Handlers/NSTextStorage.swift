//
//  Untitled.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/2/2025.
//

import AppKit
import Highlightr
import MarkdownModels

class MarkdownTextStorage: NSTextStorage {
  
  private let backingStore = NSMutableAttributedString()
  private let highlightr = Highlightr()!
  private let codeStorage = CodeAttributedString()
  
  let configuration: MarkdownEditorConfiguration
  
  init(configuration: MarkdownEditorConfiguration) {
    self.configuration = configuration
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
    fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
  }
  
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
    
    /// Apply default attributes to the entire text
    applyDefaultAttributes()
    
    /// Apply Markdown styling
    applyMarkdownStyles()
    
    /// Highlight code blocks
    highlightCodeBlocks()
  }
  
  private func applyDefaultAttributes() {
    let range = NSRange(location: 0, length: backingStore.length)
    backingStore.setAttributes(configuration.defaultTypingAttributes, range: range)
  }
  
  private func applyMarkdownStyles() {
    for syntax in Markdown.Syntax.allCases {
      styleSyntaxType(syntax: syntax)
    }
  }
  
  private func styleSyntaxType(syntax: Markdown.Syntax) {
    guard let pattern = syntax.nsRegex else { return }
    let string = backingStore.string
    
    pattern.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: backingStore.length)) { match, _, _ in
      guard let match = match else { return }
      
      var newAttrs = syntax.contentAttributes(with: configuration).attributes
      
      // Exception for `inlineCode` and `codeBlock`
      if syntax.isCodeSyntax {
//        newAttrs.updateValue(true, forKey: CodeBackground.codeBlock.attributeKey)
        newAttrs.updateValue(true, forKey: CodeBackground.inlineCode.attributeKey)
      }
      
      backingStore.addAttributes(newAttrs, range: match.range)
    }
  }
  
  private func highlightCodeBlocks() {
    let text = backingStore.string
    guard let regex = Markdown.Syntax.codeBlock.nsRegex else { return }

    regex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) { match, _, _ in
      guard let match = match else { return }
      
      let matchRange = match.range(at: 1)
      
      /// Extract the code block content and language hint
      let codeBlock = (text as NSString).substring(with: matchRange)
      let languageHint = (text as NSString).substring(with: match.range(at: 0))
        .components(separatedBy: .newlines).first?
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespaces)
      
      /// Highlight the code block using `Highlightr`
      if let highlightedCode = highlightr.highlight(codeBlock, as: languageHint) {
        backingStore.replaceCharacters(in: matchRange, with: highlightedCode)
      }
    }
  }
}
