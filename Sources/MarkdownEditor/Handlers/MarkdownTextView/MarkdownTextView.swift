//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import STTextKitPlus



public class MarkdownTextView: NSTextView {
  
  
  
  public typealias OnEvent = (_ event: NSEvent, _ action: () -> Void) -> Void
  
  private var activeScrollValue: (NSRange, CGSize)?
  private var lastSelectionValue = [NSValue]()
  
  public var onKeyDown: OnEvent = { $1() }
  public var onFlagsChanged: OnEvent = { $1() }
  public var onMouseDown: OnEvent = { $1() }
  
  let parser: MarkdownParser
  
  
  
  
  /// Deliver `NSTextView.didChangeSelectionNotification` for all selection changes.
  ///
  /// See the documenation for `setSelectedRanges(_:affinity:stillSelecting:)` for details.
  public var continuousSelectionNotifications: Bool = false
  
  public override init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?
  ) {
    let effectiveContainer = container ?? NSTextContainer()
    
    self.parser = MarkdownParser()
    
    if effectiveContainer.textLayoutManager == nil {
      let textLayoutManager = NSTextLayoutManager()
      
      textLayoutManager.textContainer = effectiveContainer
      
      let textContentStorage = NSTextContentStorage()
      
      textContentStorage.addTextLayoutManager(textLayoutManager)
      textContentStorage.primaryTextLayoutManager = textLayoutManager
      
    }
    
    super.init(frame: frameRect, textContainer: effectiveContainer)
    
    self.textViewSetup()
    
    self.parser.text = self.string
    
  }
  
  public convenience init() {
    self.init(frame: .zero, textContainer: nil)
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override var layoutManager: NSLayoutManager? {
    assertionFailure("TextKit 1 is not supported by this type")
    
    return nil
  }
  
  
  public override var intrinsicContentSize: NSSize {
    textLayoutManager?.usageBoundsForTextContainer.size ?? .zero
  }
  
  private func textViewSetup() {
    
    self.smartInsertDeleteEnabled = false
    self.autoresizingMask = .width
    self.textContainer?.widthTracksTextView = true
    self.textContainer?.heightTracksTextView = false
    self.drawsBackground = false
    self.isHorizontallyResizable = false
    self.isVerticallyResizable = true
    self.allowsUndo = true
    self.isRichText = false
    self.textContainer?.lineFragmentPadding = 30
    self.textContainerInset = NSSize(width: 0, height: 30)
    self.font = NSFont.systemFont(ofSize: 15, weight: .regular)
    self.textColor = NSColor.textColor
//    self.textContainerInset = CGSize(width: 5.0, height: 5.0)
  }
  
  
}

extension MarkdownTextView {
  open override func keyDown(with event: NSEvent) {
    onKeyDown(event) {
      super.keyDown(with: event)
    }
  }
  
  open override func flagsChanged(with event: NSEvent) {
    onFlagsChanged(event) {
      super.flagsChanged(with: event)
    }
  }
  
  open override func mouseDown(with event: NSEvent) {
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
