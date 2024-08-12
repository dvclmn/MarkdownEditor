//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI

public class MDTextView: NSTextView {
  
  
  
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
}
