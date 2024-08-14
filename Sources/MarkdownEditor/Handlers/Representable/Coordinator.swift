//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public extension MarkdownEditor {
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate {
    var parent: MarkdownEditor
    var selectedRanges: [NSValue] = []
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) {
      self.parent = parent
    }
    
    @MainActor public func textDidChange(_ notification: Notification) {
      
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.parent.text = textView.string
      self.selectedRanges = textView.selectedRanges
      self.parent.editorHeight = textView.editorHeight
      
    }
    
    @MainActor
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.selectedRanges = textView.selectedRanges
      
    }
  }
}

