//
//  ReplaceCharacters.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import STTextKitPlus


//extension MarkdownView {

//  public func replaceCharacters(in range: NSTextRange, with string: String) {
//    replaceCharacters(in: range, with: string, useTypingAttributes: true, allowsTypingCoalescing: false)
//  }
//
//  internal func replaceCharacters(in textRanges: [NSTextRange], with replacementString: String, useTypingAttributes: Bool, allowsTypingCoalescing: Bool) {
//    self.replaceCharacters(
//      in: textRanges,
//      with: NSAttributedString(string: replacementString, attributes: useTypingAttributes ? textView.typingAttributes : [:]),
//      allowsTypingCoalescing: allowsTypingCoalescing
//    )
//  }

//  internal func replaceCharacters(in textRanges: [NSTextRange], with replacementString: NSAttributedString, allowsTypingCoalescing: Bool) {
//    // Replace from the end to beginning of the document
//    for textRange in textRanges.sorted(by: { $0.location > $1.location }) {
//      replaceCharacters(in: textRange, with: replacementString, allowsTypingCoalescing: allowsTypingCoalescing)
//    }
//  }
//
//  internal func replaceCharacters(in textRange: NSTextRange, with replacementString: String, useTypingAttributes: Bool, allowsTypingCoalescing: Bool) {
//    self.replaceCharacters(
//      in: textRange,
//      with: NSAttributedString(string: replacementString, attributes: useTypingAttributes ? textView.typingAttributes : [:]),
//      allowsTypingCoalescing: allowsTypingCoalescing
//    )
//  }

//  internal func replaceCharacters(in textRange: NSTextRange, with replacementString: NSAttributedString, allowsTypingCoalescing: Bool) {
//    let previousStringInRange = (textContentManager as? NSTextContentStorage)!.attributedString!.attributedSubstring(from: NSRange(textRange, in: textContentManager))
//    
//    textWillChange(self)
//    delegateProxy.textView(self, willChangeTextIn: textRange, replacementString: replacementString.string)
//    
//    textContentManager.performEditingTransaction {
//      textContentManager.replaceContents(
//        in: textRange,
//        with: [NSTextParagraph(attributedString: replacementString)]
//      )
//    }
//    
//    delegateProxy.textView(self, didChangeTextIn: textRange, replacementString: replacementString.string)
//    didChangeText(in: textRange)
//    
//    guard allowsUndo, let undoManager = undoManager, undoManager.isUndoRegistrationEnabled else { return }
//    
//    // Reach to NSTextStorage because NSTextContentStorage range extraction is cumbersome.
//    // A range that is as long as replacement string, so when undo it undo
//    let undoRange = NSTextRange(
//      location: textRange.location,
//      end: textContentManager.location(textRange.location, offsetBy: replacementString.length)
//    ) ?? textRange
//    
//    if let coalescingUndoManager = undoManager as? CoalescingUndoManager, !undoManager.isUndoing, !undoManager.isRedoing {
//      if allowsTypingCoalescing && processingKeyEvent {
//        coalescingUndoManager.checkCoalescing(range: undoRange)
//      } else {
//        coalescingUndoManager.endCoalescing()
//      }
//    }
//    undoManager.beginUndoGrouping()
//    undoManager.registerUndo(withTarget: self) { textView in
//      // Regular undo action
//      textView.replaceCharacters(
//        in: undoRange,
//        with: previousStringInRange,
//        allowsTypingCoalescing: false
//      )
//      textView.setSelectedTextRange(textRange)
//    }
//    undoManager.endUndoGrouping()
//    }
//}
