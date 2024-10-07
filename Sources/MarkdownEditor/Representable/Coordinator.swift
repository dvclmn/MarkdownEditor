//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import TextCore

//import Rearrange
//import STTextKitPlus

public extension MarkdownEditor {
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
    
    var parent: MarkdownEditor
    weak var textView: MarkdownTextView?
    
    var selectedRanges: [NSValue] = []
    var selections: [NSTextSelection] = []
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) { self.parent = parent }

    
    public func textStorage(
      _ textStorage: NSTextStorage,
      didProcessEditing editedMask: NSTextStorageEditActions,
      range editedRange: NSRange,
      changeInLength delta: Int
    ) {
      guard let textView = textView else {
        print("Issue getting the text view, within the `NSTextStorageDelegate`")
        return
      }
      
      Task { @MainActor in
        textView.parseAndRedraw()
      }
    }
    
    public func textDidChange(_ notification: Notification) {
      
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
              
      else { return }
      
      self.parent.text = textView.string
      self.selectedRanges = textView.selectedRanges
      
      /// I have learned, and need to remember, that this `Coordinator` is
      /// a delegate, for my ``MarkdownTextView``. Which means I can take
      /// full advantage of methods here, just like I can with overrides in `MarkdownTextView`. They often have different functionalities to
      /// experiment with.
      
    }
    
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
