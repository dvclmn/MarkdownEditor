//
//  Untitled.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/2/2025.
//

import AppKit
import Highlightr
import MarkdownModels
import Rearrange

class MarkdownTextStorage: NSTextStorage {

  private let backingStore = NSMutableAttributedString()
  private let highlightr = Highlightr()
  private let codeStorage = CodeAttributedString()

  let configuration: MarkdownEditorConfiguration

  init(configuration: MarkdownEditorConfiguration) {
    self.configuration = configuration
    super.init()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType)
  {
    fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
  }

  override var string: String {
    backingStore.string
  }

  override func attributes(
    at location: Int, effectiveRange range: NSRangePointer?
  ) -> [NSAttributedString.Key: Any] {
    backingStore.attributes(at: location, effectiveRange: range)
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
      
      
      //      styleSyntaxTypeWithRegexLiteral(syntax: syntax)
      styleSyntaxType(syntax: syntax)
    }
  }


  private func styleSyntaxTypeWithRegexLiteral(syntax: Markdown.Syntax) {
    fatalError("Not yet implemented.")
  }


  private func styleSyntaxType(syntax: Markdown.Syntax) {
    guard let pattern = syntax.nsRegex else { return }
    let string = backingStore.string
    
    guard !syntax.isHorizontalRule else { return styleHorizontalRule(syntax: syntax) }

    pattern.enumerateMatches(
      in: string, options: [], range: NSRange(location: 0, length: backingStore.length)
    ) { match, _, _ in
      guard let match = match else { return }

      if match.numberOfRanges == 4 {
        let openingSyntaxRange = match.range(at: 1)
        backingStore.addAttributes(
          syntax.syntaxAttributes(with: configuration).attributes, range: openingSyntaxRange)

        let contentRange = match.range(at: 2)
        backingStore.addAttributes(
          syntax.contentAttributes(with: configuration).attributes, range: contentRange)

        let closingSyntaxRange = match.range(at: 3)
        backingStore.addAttributes(
          syntax.syntaxAttributes(with: configuration).attributes, range: closingSyntaxRange)
      } else  {
        /// Fallback in case you don’t have exactly three capture groups
        backingStore.addAttributes(
          syntax.contentAttributes(with: configuration).attributes, range: match.range)
      }
    }
  }

  private func highlightCodeBlocks() {
    guard let regex = Markdown.Syntax.codeBlock.nsRegex else { return }
    let text = backingStore.string

    regex.enumerateMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
      match, _, _ in
      guard let match = match else { return }

      /// Get the full range including backticks
      let fullRange = match.range(at: 1)

      /// Extract the code content (without backticks and language hint)
      let codeBlock = (text as NSString).substring(with: fullRange)
      let lines = codeBlock.components(separatedBy: .newlines)

      /// Extract language hint from the first line
      let languageHint = lines.first?
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespaces)

      /// Highlight the code

      guard let highlightr else { return }

      highlightr.setTheme(to: "devibeans")
      
      guard let highlightedCode = highlightr.highlight(codeBlock, as: languageHint ?? "txt") else {
        return
      }

      /// Create attributed string with the highlighted code
      let attributedCode = NSMutableAttributedString(attributedString: highlightedCode)

      /// Add the code block background attribute to the entire range
      attributedCode.addAttribute(
        TextBackground.codeBlock.attributeKey,
        value: true,
        range: NSRange(location: 0, length: attributedCode.length))

      /// Replace the content while preserving the backticks
      backingStore.replaceCharacters(in: fullRange, with: attributedCode)

    }
  }
}


extension MarkdownTextStorage {
  private func styleHorizontalRule(syntax: Markdown.Syntax) {
    guard let pattern = syntax.nsRegex else { return }
    let string = backingStore.string
    
    pattern.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: backingStore.length)) { match, _, _ in
      guard let match = match else { return }
      
      // Create the horizontal rule attachment
      let attachment = HorizontalRuleAttachment()
      let attachmentString = NSAttributedString(attachment: attachment)
      
      // Replace the markdown syntax with the attachment
      backingStore.replaceCharacters(in: match.range, with: attachmentString)
    }
  }
//  func styleHorizontalRule(syntax: Markdown.Syntax) {
//    guard case .horizontalRule = syntax,
//          let pattern = syntax.nsRegex else { return }
//    
//    let string = backingStore.string
//    pattern.enumerateMatches(
//      in: string,
//      options: [],
//      range: NSRange(location: 0, length: backingStore.length)
//    ) { match, _, _ in
//      guard let match = match else { return }
//      
//      // Create the attachment
//      let attachment = HorizontalRuleAttachment(
//        color: NSColor.purple,
//        thickness: 2
//      )
//      
//      // Create an attributed string with the attachment
//      let attachmentString = NSAttributedString(
//        attachment: attachment
//      )
//      
//      // Replace the original horizontal rule characters with the attachment
//      backingStore.replaceCharacters(
//        in: match.range,
//        with: attachmentString
//      )
//    }
//  }
}
