//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import BaseHelpers
//import Rearrange
//import STTextKitPlus

public extension MarkdownEditor {
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator:
    NSObject,
    NSTextViewDelegate,
    NSTextStorageDelegate,
    NSTextContentStorageDelegate,
    NSTextLayoutManagerDelegate {
    
    var parent: MarkdownEditor
    weak var textView: MarkdownTextView?
    
    var selectedRanges: [NSValue] = []

    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) { self.parent = parent }
    
    var attachmentRanges: Array<NSRange> = []
    
    
   
    
//    // Returning a ParItemAttachmentTextElement if there is a ParagraphItemAttachment in the text range
//    public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
//      if let attributedString = textContentStorage.attributedString {
//        self.attachmentRanges = Array()
//        attributedString.enumerateAttribute(.attachment, in: range) { (attachment: Any?, characterRange:NSRange, stopIt: UnsafeMutablePointer<ObjCBool>) in
//          if let _ = attachment as? MarkdownTextView.HighlightTextAttachment {
//            self.attachmentRanges.append(characterRange)
//          }
//        }
//        if !self.attachmentRanges.isEmpty {
//          let textElementAttributedString = attributedString.attributedSubstring(from: range)
////          let textRange = textContentStorage.textElement(for: )
////          let parItemTextElement = ParItemAttachmentTextParagraph(attributedString: textElementAttributedString, textContentManager: textContentStorage, elementRange: textRange, attachmentRanges: self.attachmentRanges)
////          return parItemTextElement
//        }
//      }
//      return nil
//    }
//    
    //
    //    @MainActor public func textStorage(
    //      _ textStorage: NSTextStorage,
    //      didProcessEditing editedMask: NSTextStorageEditActions,
    //      range editedRange: NSRange,
    //      changeInLength delta: Int
    //    ) {
    //      guard let textView = textView else {
    //        print("Issue getting the text view, within the `NSTextStorageDelegate`")
    //        return
    //      }
    //
    //
    //
    //      textView.parseAndRedraw()
    //
    //      Task { @MainActor in
    //
    //        let currentLines = currentLineCount()
    //
    //         Check if the number of lines has changed
    //        if currentLines != lastLineCount {
    //          lastLineCount = currentLines
    //
    //           Trigger expensive operations
    //
    //        } else {
    //           Optional: Handle minimal updates if necessary
    //           For example, updating line-specific highlights
    //        }
    //
    //
    //      }
    //    }
    

    
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.selectedRanges = textView.selectedRanges
      
    }
    
    //    public func textViewWillChangeText() {
    
    //    }
    

  }
}
