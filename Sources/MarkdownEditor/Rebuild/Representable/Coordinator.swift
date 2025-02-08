//
//  Coordinator.swift
//  Components
//
//  Created by Dave Coleman on 7/2/2025.
//

import BaseHelpers
import SwiftUI
import MarkdownModels

extension TempEditor {
  public class Coordinator: NSObject, NSTextViewDelegate {
    let parent: TempEditor

    public init(_ view: TempEditor) {
      self.parent = view
    }
    public func textDidChange(_ notification: Notification) {
      print("Ran `textDidChange`")
      guard let textView = notification.object as? NSTextView else { return }
      
      /// Update the binding with the latest text.
      parent.text = textView.string
      
      /// Apply syntax highlighting.
      parent.styleText(textView: textView)
    }  // END text did change
  }
}

extension TempEditor {
  func styleText(textView: NSTextView) {
    print("Ran `styleText`")
    guard let textStorage = textView.textStorage else { return }
    
    let fullRange = NSRange(location: 0, length: textStorage.length)
    
    textStorage.beginEditing()
    
    /// Explicitly remove all custom attributes
    let cleanAttributes: [NSAttributedString.Key: Any] = [
      .font: textView.font ?? NSFont.systemFont(ofSize: config.theme.fontSize),
      .foregroundColor: NSColor.textColor,
      .inlineCode: false
    ]
    textStorage.setAttributes(cleanAttributes, range: fullRange)
    
    guard let inlineCodePattern = Markdown.Syntax.inlineCode.nsRegex else {
      textStorage.endEditing()
      return
    }
    
    let string = textView.string
    
    // Enumerate matches for inline code
    inlineCodePattern.enumerateMatches(in: string, options: [], range: fullRange) { match, _, _ in
      guard let match = match,
            match.numberOfRanges == 4 else { return }
      
      /// Get the range of just the content between backticks
      let contentRange = match.range(at: 2)
      
      /// Only style if we have both opening and closing backticks
      let fullMatchString = (string as NSString).substring(with: match.range)
      guard fullMatchString.hasPrefix("`") && fullMatchString.hasSuffix("`") else { return }
      
      /// Define attributes for inline code
      let monoFont = NSFont.monospacedSystemFont(
        ofSize: textView.font?.pointSize ?? config.theme.codeFontSize,
        weight: .regular)
      
      let newAttrs: [NSAttributedString.Key: Any] = [
        .inlineCode: true,
        .font: monoFont,
        .foregroundColor: config.theme.codeColour,
      ]
      
      /// Apply attributes only to the content between backticks
      textStorage.addAttributes(newAttrs, range: contentRange)
    }
    
    textStorage.endEditing()
  }
}
