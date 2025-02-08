//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import BaseHelpers
import SwiftUI
import MarkdownModels

//import Rearrange
//import STTextKitPlus

extension MarkdownEditor {

  public class Coordinator: NSObject, NSTextViewDelegate {
    let parent: MarkdownEditor

    //    var selectedRanges: [NSValue] = []

    public init(_ view: MarkdownEditor) {
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

    //    public func textViewDidChangeSelection(_ notification: Notification) {
    //      guard let textView = notification.object as? MarkdownTextView
    //      else { return }
    //
    //      self.selectedRanges = textView.selectedRanges
    //
    //    }

  }

}

extension MarkdownEditor {
  func styleText(textView: NSTextView) {
    print("Ran `styleText`")
    guard let textStorage = textView.textStorage else { return }
    
    let fullRange = NSRange(location: 0, length: textStorage.length)
    
    textStorage.beginEditing()
    
    /// Explicitly remove all custom attributes
    let cleanAttributes: [NSAttributedString.Key: Any] = [
      .font: textView.font ?? NSFont.systemFont(ofSize: configuration.theme.fontSize),
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
        ofSize: textView.font?.pointSize ?? configuration.theme.codeFontSize,
        weight: .regular)
      
      let newAttrs: [NSAttributedString.Key: Any] = [
        .inlineCode: true,
        .font: monoFont,
        .foregroundColor: configuration.theme.codeColour,
      ]
      
      /// Apply attributes only to the content between backticks
      textStorage.addAttributes(newAttrs, range: contentRange)
    }
    
    textStorage.endEditing()
  }
}
