//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public extension MarkdownEditor {
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate {
    var parent: MarkdownEditor
    var selectedRanges: [NSValue] = []
    var updatingNSView = false
    
//    private var debouncedScrollTask: Task<Void, Never>?
    
    init(_ parent: MarkdownEditor) {
      self.parent = parent
    }
    
    
//    func debouncedScrollChange(_ newOffset: CGPoint) {
//      debouncedScrollTask?.cancel()
//      debouncedScrollTask = Task {
//        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second debounce
//        if !Task.isCancelled {
//          // Handle debounced scroll change here
//          // You can call parent.textInfo, parent.selectionInfo, etc.
//          print("Debounced scroll offset changed to: \(newOffset)")
//        }
//      }
//    }
    
    
    
    @MainActor public func textDidChange(_ notification: Notification) {
      
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.parent.text = textView.string
      self.selectedRanges = textView.selectedRanges
      
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

