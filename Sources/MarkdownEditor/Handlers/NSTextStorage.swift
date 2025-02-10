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
    fatalError("Not implemented")
  }

  required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType)
  {
    fatalError("Not implemented")
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
    applyDefaultAttributes()
    applyMarkdownStyles()
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
    let text = backingStore.string

    processRegexMatches(for: syntax, in: text, using: pattern) { ranges in
      /// Apply leading syntax attributes
      backingStore.addAttributes(
        syntax.syntaxAttributes(with: configuration).attributes,
        range: ranges.leading
      )

      /// Apply content attributes
      backingStore.addAttributes(
        syntax.contentAttributes(with: configuration).attributes,
        range: ranges.content
      )

      /// Apply closing syntax attributes
      backingStore.addAttributes(
        syntax.syntaxAttributes(with: configuration).attributes,
        range: ranges.trailing
      )
    }
  }


  //  private func highlightCodeBlocks() {
  //
  //    self.beginEditing()
  //    guard let regex = Markdown.Syntax.codeBlock.nsRegex else { return }
  //    let text = backingStore.string
  //    let range = NSRange(location: 0, length: backingStore.length)
  //
  //    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
  //      guard let match = match else { return }
  //
  //      // Ensure the match range is valid
  //      if match.range.location + match.range.length <= backingStore.length {
  //
  //        /// Extract the code content (without backticks and language hint)
  //        let codeBlock = (text as NSString).substring(with: fullRange)
  //        let lines = codeBlock.components(separatedBy: .newlines)
  //
  //        /// Extract language hint from the first line
  //        let languageHint = lines.first?
  //          .replacingOccurrences(of: "```", with: "")
  //          .trimmingCharacters(in: .whitespaces)
  //
  //        /// Highlight the code
  //        guard let highlightr else { return }
  ////        highlightr.setTheme(to: "devibeans")
  //        guard let highlightedCode = highlightr.highlight(codeBlock, as: languageHint ?? "txt")
  //        else {
  //          return
  //        }
  //        /// Create attributed string with the highlighted code
  //        let attributedCode = NSMutableAttributedString(attributedString: highlightedCode)
  //
  //        /// Add the code block background attribute to the entire range
  //        attributedCode.addAttribute(
  //          TextBackground.codeBlock.attributeKey,
  //          value: true,
  //          range: NSRange(location: 0, length: attributedCode.length))
  //
  //        /// Replace the content while preserving the backticks
  //        backingStore.replaceCharacters(in: fullRange, with: attributedCode)
  //      }
  //    }
  //    self.endEditing()
  //  }

  private func processRegexMatches(
    for syntax: Markdown.Syntax,
    in text: String,
    using pattern: NSRegularExpression,
    applyAttributes: (MarkdownRanges) -> Void
  ) {
    let range = NSRange(location: 0, length: backingStore.length)

    pattern.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
      guard let match = match else { return }

      /// Ensure the match range is valid
      guard match.range.location + match.range.length <= backingStore.length else {
        print("Invalid range: \(match.range) for string length: \(backingStore.length)")
        return
      }
      switch syntax {
        case .bold, .italic, .boldItalic, .strikethrough, .inlineCode, .highlight:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          let trailingRange = match.range(at: 3)

          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: trailingRange
          )
          applyAttributes(ranges)


        case .heading, .quoteBlock:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)

          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: .zero
          )
          applyAttributes(ranges)


        case .list:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          
          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: .zero
          )
          applyAttributes(ranges)
          
          
        case .link, .image:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          let urlRange = match.range(at: 4)

          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: urlRange
          )
          applyAttributes(ranges)


        case .codeBlock:
          let leadingRange = match.range(at: 1)
          let contentRange = match.range(at: 2)
          let trailingRange = match.range(at: 3)

          let ranges = MarkdownRanges(
            all: match.range,
            leading: leadingRange,
            content: contentRange,
            trailing: trailingRange
          )
          applyAttributes(ranges)

        default:
          break
      }
    }
  }

  //  private func processRegexMatches(
  //    for syntax: Markdown.Syntax,
  //    in text: String,
  //    using pattern: NSRegularExpression,
  //    applyAttributes: (MarkdownRanges) -> Void
  //  ) {
  //    let range = NSRange(location: 0, length: backingStore.length)
  //
  //    pattern.enumerateMatches(in: text, options: [], range: range) {
  //      match, _, _ in
  //      guard let match = match else { return }
  //
  //      /// Ensure the match range is valid
  //      if match.range.location + match.range.length <= backingStore.length {
  //        if match.numberOfRanges == 4 {
  //          /// Extract capture groups
  //          let openingSyntaxRange = match.range(at: 1)
  //          let contentRange = match.range(at: 2)
  //          let closingSyntaxRange = match.range(at: 3)
  //
  //          /// Apply attributes using the provided closure
  //          let ranges = MarkdownRanges(
  //            all: match.range,
  //            leading: openingSyntaxRange,
  //            content: contentRange,
  //            trailing: closingSyntaxRange
  //          )
  //          applyAttributes(ranges)
  //        } else {
  //          fatalError("Figure this out")
  //          let ranges = MarkdownRanges(
  //            all: match.range,
  //            leading: .zero,
  //            content: .zero,
  //            trailing: .zero
  //          )
  //          /// Fallback for simpler patterns
  //          applyAttributes(ranges)
  //        }
  //      } else {
  //        print("Invalid range: \(match.range) for string length: \(backingStore.length)")
  //      }
  //    }
  //  }


  private func highlightCodeBlocks() {
    self.beginEditing()
    guard let regex = Markdown.Syntax.codeBlock.nsRegex else { return }
    let text = backingStore.string
    let range = NSRange(location: 0, length: backingStore.length)
    
    regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
      guard let match = match else { return }
      
      guard match.range.location + match.range.length <= backingStore.length else { return }
      
      let fullRange = match.range
      let codeBlock = (text as NSString).substring(with: fullRange)
      let lines = codeBlock.components(separatedBy: .newlines)
      
      let languageHint = lines.first?
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespaces)
      
      guard let highlightr = highlightr,
            let highlightedCode = highlightr.highlight(codeBlock, as: languageHint ?? "txt")
      else {
        return
      }
      
      let attributedCode = NSMutableAttributedString(attributedString: highlightedCode)
      attributedCode.addAttribute(
        TextBackground.codeBlock.attributeKey,
        value: true,
        range: NSRange(location: 0, length: attributedCode.length)
      )
      
      backingStore.replaceCharacters(in: fullRange, with: attributedCode)
      
    }
    self.endEditing()
  }
  
}

struct MarkdownRanges {
  let all: NSRange
  let leading: NSRange
  let content: NSRange
  let trailing: NSRange
}
