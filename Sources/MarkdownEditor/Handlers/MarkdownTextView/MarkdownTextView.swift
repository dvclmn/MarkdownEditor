//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import STTextKitPlus


extension Notification.Name {
  static let metricsDidChange = Notification.Name("metricsDidChange")
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

extension MarkdownTextView: NSTextLayoutManagerDelegate {
  public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
    if let markdownParagraph = textElement as? MarkdownParagraph {
      return InlineCodeLayoutFragment(textElement: markdownParagraph, range: markdownParagraph.elementRange)
    }
    return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
  }
}



public class MarkdownTextView: NSTextView {
  
  var inlineCodeElements: [InlineCodeElement] = []
  
  var editorMetrics: String = ""
  
  public typealias OnEvent = (_ event: NSEvent, _ action: () -> Void) -> Void
  
  private var activeScrollValue: (NSRange, CGSize)?
  private var lastSelectionValue = [NSValue]()
  
  public var onKeyDown: OnEvent = { $1() }
  public var onFlagsChanged: OnEvent = { $1() }
  public var onMouseDown: OnEvent = { $1() }
  
  //  let parser: MarkdownParser
  
  
  
  
  /// Deliver `NSTextView.didChangeSelectionNotification` for all selection changes.
  ///
  /// See the documenation for `setSelectedRanges(_:affinity:stillSelecting:)` for details.
  public var continuousSelectionNotifications: Bool = false
  
  public override init(
    frame frameRect: NSRect = .zero,
    textContainer container: NSTextContainer? = nil
  ) {
    //    self.parser = MarkdownParser()
    
    let container = NSTextContainer()
    
    let textLayoutManager = MarkdownLayoutManager()
    
    textLayoutManager.textContainer = container
    
    let textContentStorage = MarkdownContentStorage()
    
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    
    super.init(frame: frameRect, textContainer: container)
    
    self.textViewSetup()
    
    //    self.parser.text = self.string
    
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  //
  //  func parseInlineCode() {
  //    guard let textContentManager = self.textLayoutManager?.textContentManager else { return }
  //
  //    inlineCodeElements.removeAll()
  //
  ////    let fullRange = NSRange(location: 0, length: string.utf16.count)
  //    let regex = MarkdownSyntax.inlineCode.regex
  //
  //    regex.
  //
  //    regex.enumerateMatches(in: string, options: [], range: fullRange) { match, _, _ in
  //      if let matchRange = match?.range {
  //        let element = InlineCodeElement(range: matchRange)
  //        inlineCodeElements.append(element)
  //
  //        textContentManager.performEditingTransaction {
  //          textContentManager.addTextElement(element, for: NSTextRange(matchRange, in: textContentManager))
  //        }
  //      }
  //    }
  //
  //    print("Found \(inlineCodeElements.count) inline code elements")
  //  }
  //
  //
  
  
  public override var layoutManager: NSLayoutManager? {
    assertionFailure("TextKit 1 is not supported by this type")
    return nil
  }
  
  
  public override var intrinsicContentSize: NSSize {
    textLayoutManager?.usageBoundsForTextContainer.size ?? .zero
  }
  
  func assembleMetrics() {
    guard let documentRange = self.textLayoutManager?.documentRange else { return }
    
    var textElementCount: Int = 0
    
    textLayoutManager?.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
      textElementCount += 1
      return true
    })
    
//    DispatchQueue.main.async {
      self.editorMetrics = """
      Editor height: \(self.intrinsicContentSize.height.description)
      Character count: \(self.string.count)
      Text elements: \(textElementCount.description)
      Document range: \(documentRange.description)
      """
//    }
    NotificationCenter.default.post(name: .metricsDidChange, object: self)
    
  }
  
}

extension MarkdownTextView {
  
  public override func didChangeText() {
    super.didChangeText()
    assembleMetrics()
    //    parseInlineCode()
    
  }
  
  public override func keyDown(with event: NSEvent) {
    onKeyDown(event) {
      super.keyDown(with: event)
    }
  }
  
  public override func flagsChanged(with event: NSEvent) {
    onFlagsChanged(event) {
      super.flagsChanged(with: event)
    }
  }
  
  public override func mouseDown(with event: NSEvent) {
    onMouseDown(event) {
      super.mouseDown(with: event)
    }
  }
}




//  public override var intrinsicContentSize: NSSize {
//
//    guard let textLayoutManager = self.textla,
//          let textContainer = self.textContainer
//    else { return .zero }
//
//    layoutManager.ensureLayout(for: textContainer)
//
//    return layoutManager.usedRect(for: textContainer).size
//
//  }

//  public override func didChangeText() {
//    super.didChangeText()
//

// Assuming you have a way to detect markdown code blocks
//    let codeBlockRanges = detectCodeBlocks(in: self.string)




//  }

//  func drawCodeBlockBackground(in ranges: [NSRange]) {
//
//  }

//  // Implement your code block detection logic here
//  func detectCodeBlocks(in string: String) -> [NSRange] {
//    // Your implementation to detect code blocks
//    // Return an array of NSRanges representing code blocks
//  }

//   var wrappingConfigs: [WrappingConfig] = []


//   func configureWrappingSyntax(_ configs: [WrappingConfig]) {
//      self.wrappingConfigs = configs
//   }

//   public override func performKeyEquivalent(with event: NSEvent) -> Bool {
//      for config in wrappingConfigs {
//         if let shortcut = config.shortcut, matchesKeyEquivalent(event, shortcut: shortcut) {
//            textView.wrapSelection(with: config.syntax)
//            return true
//         }
//      }
//      return super.performKeyEquivalent(with: event)
//   }
//   private func matchesKeyEquivalent(_ event: NSEvent, shortcut: String) -> Bool {
//      // Implement logic to match the event with the shortcut string
//      // This is a simplified example and may need to be expanded based on your shortcut format
//      let keyEquivalent = event.charactersIgnoringModifiers ?? ""
//      let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
//
//      let shortcutParts = shortcut.split(separator: "+")
//      let shortcutKey = String(shortcutParts.last ?? "")
//      let shortcutModifiers = Set(shortcutParts.dropLast())
//
//      let matchesKey = keyEquivalent.lowercased() == shortcutKey.lowercased()
//      let matchesModifiers = Set(modifierFlags.description.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }) == shortcutModifiers
//
//      return matchesKey && matchesModifiers
//   }

//   public override func keyDown(with event: NSEvent) {
//      if let characters = event.characters,
//         let config = wrappingConfigs.first(where: { $0.triggerKey == characters }) {
//         wrapSelection(with: config.syntax)
//      } else {
//         super.keyDown(with: event)
//      }
//   }

//   func wrapSelection(with syntax: WrappableSyntax) {
//      guard let selectedRange = self.selectedRanges.first as? NSRange,
//            selectedRange.length > 0,
//            let textStorage = self.textStorage else {
//         return
//      }
//
//      textStorage.beginEditing()
//
//      // Insert closing symbol
//      textStorage.replaceCharacters(in: NSRange(location: selectedRange.location + selectedRange.length, length: 0), with: syntax.closingSymbol)
//
//      // Insert opening symbol
//      textStorage.replaceCharacters(in: NSRange(location: selectedRange.location, length: 0), with: syntax.openingSymbol)
//
//      textStorage.endEditing()
//
//      // Adjust the selection to place the insertion point at the end of the newly-wrapped string
//      let newRange = NSRange(location: selectedRange.location + selectedRange.length + syntax.openingSymbol.count + syntax.closingSymbol.count, length: 0)
//      self.selectedRanges = [NSValue(range: newRange)]
//
//      // Trigger re-highlighting
//      if let fullText = self.string as NSString? {
//         let highlightedText = MarkdownEditor.getHighlightedText(text: fullText as String)
//         self.textStorage?.setAttributedString(highlightedText)
//      }
//   }


//   var wrappingConfigs: [WrappingConfig] = []
//
//   func configureWrappingSyntax(_ configs: [WrappingConfig]) {
//      self.wrappingConfigs = configs
//   }
//
//   override func keyDown(with event: NSEvent) {
//      if let characters = event.characters,
//         let config = wrappingConfigs.first(where: { $0.triggerKey == characters }) {
//         wrapSelection(with: config.syntax)
//      } else {
//         super.keyDown(with: event)
//      }
//   }
//
//   func wrapSelection(with syntax: WrappableSyntax) {
//      guard let selectedRange = self.selectedRanges.first as? NSRange,
//            selectedRange.length > 0,
//            let textStorage = self.textStorage else {
//         return
//      }
//
//      textStorage.beginEditing()
//
//      // Insert closing symbol
//      textStorage.replaceCharacters(in: NSRange(location: selectedRange.location + selectedRange.length, length: 0), with: syntax.closingSymbol)
//
//      // Insert opening symbol
//      textStorage.replaceCharacters(in: NSRange(location: selectedRange.location, length: 0), with: syntax.openingSymbol)
//
//      textStorage.endEditing()
//
//      // Adjust the selection to place the insertion point at the end of the newly-wrapped string
//      let newRange = NSRange(location: selectedRange.location + selectedRange.length + syntax.openingSymbol.count + syntax.closingSymbol.count, length: 0)
//      self.selectedRanges = [NSValue(range: newRange)]
//
//      // Trigger re-highlighting
//      if let fullText = self.string as NSString? {
//         let highlightedText = MarkdownEditor.getHighlightedText(text: fullText as String)
//         self.textStorage?.setAttributedString(highlightedText)
//      }
//   }



//   public override func keyDown(with event: NSEvent) {
//      if event.charactersIgnoringModifiers == "`" && self.selectedRange().length > 0 {
//         wrapSelectionWithBackticks()
//      } else {
//         super.keyDown(with: event)
//      }
//   }

//   private func wrapSelectionWithBackticks() {
//      guard let selectedRange = self.selectedRanges.first as? NSRange,
//            selectedRange.length > 0,
//            let textStorage = self.textStorage else {
//         return
//      }
//
//      textStorage.beginEditing()
//
//      // Insert closing backtick
//      textStorage.replaceCharacters(in: NSRange(location: selectedRange.location + selectedRange.length, length: 0), with: "`")
//
//      // Insert opening backtick
//      textStorage.replaceCharacters(in: NSRange(location: selectedRange.location, length: 0), with: "`")
//
//      textStorage.endEditing()
//
//      // Option 1: Keep the full newly-wrapped string selected
//      let fullSelectionRange = NSRange(location: selectedRange.location, length: selectedRange.length + 2)
//
//      // Option 2: Place the insertion point at the end of the newly-wrapped string
//      let insertionPointRange = NSRange(location: selectedRange.location + selectedRange.length + 2, length: 0)
//
//      // Choose which option to use (you can make this a setting or parameter)
//      let newRange = insertionPointRange // or fullSelectionRange
//
//
//      // Trigger re-highlighting
//      if let fullText = self.string as NSString? {
//         let highlightedText = MarkdownEditor.getHighlightedText(text: fullText as String)
//         self.textStorage?.setAttributedString(highlightedText)
//      }
//
//      self.selectedRanges = [NSValue(range: newRange)]
//
//   }

fileprivate let NSOldSelectedCharacterRanges = "NSOldSelectedCharacterRanges"
