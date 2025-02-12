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

public class MarkdownTextStorage: NSTextStorage {

  private let backingStore = NSMutableAttributedString()
  private let highlightr = Highlightr()
//  private let codeStorage = CodeAttributedString()
  let configuration: EditorConfiguration
  
  private var currentProcessingTask: Task<Void, Never>?
  private var lastProcessedText: String?
  private var isProcessingEnabled = true
  
  private let cache = MarkdownCache.shared
  
  var processingStateChanged: ((Bool) -> Void)?

  init(configuration: EditorConfiguration) {
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

  public override var string: String {
    backingStore.string
  }

  public override func attributes(
    at location: Int, effectiveRange range: NSRangePointer?
  ) -> [NSAttributedString.Key: Any] {
    backingStore.attributes(at: location, effectiveRange: range)
  }

  public override func replaceCharacters(in range: NSRange, with str: String) {
    beginEditing()
    backingStore.replaceCharacters(in: range, with: str)
    edited(.editedCharacters, range: range, changeInLength: str.count - range.length)
    endEditing()
    /// Trigger async processing
    scheduleProcessing()
  }

  public override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(.editedAttributes, range: range, changeInLength: 0)
    endEditing()
  }
  
  private func processText(_ text: String) async {
    processingStateChanged?(true)
    
    guard let highlightr else {
      fatalError("Error initializing Highlightr")
    }
    
    let processed = await cache.cachedText(for: text) { inputText in
      ProcessedMarkdown.process(
        text: inputText,
        configuration: self.configuration,
        highlightr: highlightr
//        codeStorage: self.codeStorage
      ).attributedString
    }
    
    await MainActor.run {
      guard !Task.isCancelled else { return }
      
      self.beginEditing()
      self.backingStore.setAttributedString(processed)
      self.edited(.editedAttributes, range: NSRange(location: 0, length: self.length), changeInLength: 0)
      self.endEditing()
      
      self.lastProcessedText = text
      self.processingStateChanged?(false)
    }
  }
  
  // Helper method to temporarily disable processing (useful during bulk updates)
  func performWithoutProcessing(_ updates: () -> Void) {
    isProcessingEnabled = false
    updates()
    isProcessingEnabled = true
    scheduleProcessing()
  }
  
  // Add this method to force immediate processing
  func forceProcessing() {
    scheduleProcessing()
  }

//  public override func processEditing() {
//    super.processEditing()
//    applyDefaultAttributes()
//    applyMarkdownStyles()
//    highlightCodeBlocks()
//  }
//  
  private func scheduleProcessing() {
    guard isProcessingEnabled else { return }
    
    // Cancel any existing processing
    currentProcessingTask?.cancel()
    
    currentProcessingTask = Task {
//      guard let self = self else { return }
      
      // Debounce by waiting a bit
      try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
      guard !Task.isCancelled else { return }
      
      let currentText = self.string
      guard currentText != self.lastProcessedText else { return }
      
      await self.processText(currentText)
    }
  }
  

  private func applyDefaultAttributes() {
    let range = NSRange(location: 0, length: backingStore.length)
    backingStore.setAttributes(configuration.defaultTypingAttributes, range: range)
  }

//  private func applyMarkdownStyles() {
//    for syntax in Markdown.Syntax.allCases {
//      styleSyntaxType(syntax: syntax)
//    }
//  }




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



  
}

struct MarkdownRanges {
  let all: NSRange
  let leading: NSRange
  let content: NSRange
  let trailing: NSRange
}
