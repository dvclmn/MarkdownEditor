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
  
//        
//        // Convert the Swift ranges to NSRange (for use with the AppKit APIs)
//        let nsLeadingRange = NSRange(leadingRange, in: text)
//        let nsContentRange = NSRange(contentRange, in: text)
//        let nsTrailingRange = NSRange(trailingRange, in: text)
//        
//        // Apply syntax (marker) attributes to the leading and trailing parts.
//        backingStore.addAttributes(syntax.syntaxAttributes(with: configuration).attributes,
//                                   range: nsLeadingRange)
//        backingStore.addAttributes(syntax.syntaxAttributes(with: configuration).attributes,
//                                   range: nsTrailingRange)
//        
//        // Apply content attributes to the inner text.
//        backingStore.addAttributes(syntax.contentAttributes(with: configuration).attributes,
//                                   range: nsContentRange)
//        
//      } else {
//        // Fallback: if for some reason the named capture groups aren’t found,
//        // you may apply content styling to the entire match.
//        let fullRange = NSRange(match.range, in: text)
//        backingStore.addAttributes(syntax.contentAttributes(with: configuration).attributes,
//                                   range: fullRange)
//      }
    }

  
  private func styleSyntaxType(syntax: Markdown.Syntax) {
    guard let pattern = syntax.nsRegex else { return }
    let string = backingStore.string
    
    pattern.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: backingStore.length)) { match, _, _ in
      guard let match = match else { return }
      
//      var newAttrs = syntax.contentAttributes(with: configuration).attributes
      
//      if syntax.isCodeSyntax {
//        newAttrs.updateValue(true, forKey: CodeBackground.inlineCode.attributeKey)
//      }

      /// If our regex was designed to capture three groups:
      /// fullMatch = group 0, syntax1 = group 1, content = group 2, syntax2 = group 3.
      if match.numberOfRanges == 4 {
        
        let openingSyntaxRange = match.range(at: 1)
        backingStore.addAttributes(syntax.syntaxAttributes(with: configuration).attributes, range: openingSyntaxRange)
        
        
        let contentRange = match.range(at: 2)
        backingStore.addAttributes(syntax.contentAttributes(with: configuration).attributes, range: contentRange)
        
        
        let closingSyntaxRange = match.range(at: 3)
        backingStore.addAttributes(syntax.syntaxAttributes(with: configuration).attributes, range: closingSyntaxRange)
      } else {
        /// Fallback in case you don’t have exactly three capture groups
        backingStore.addAttributes(syntax.contentAttributes(with: configuration).attributes, range: match.range)
      }
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
        backingStore.addAttribute(CodeBackground.codeBlock.attributeKey, value: true, range: matchRange)
      }
    }
  }
}
