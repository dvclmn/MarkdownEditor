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
  
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate, NSTextLayoutManagerDelegate {
    var parent: MarkdownEditor
    var selectedRanges: [NSValue] = []
    
    var selections: [NSTextSelection] = []
    
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) {
      self.parent = parent
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
//      Task {
//        textView.processingTime = await textView.processFullDocumentWithTiming(textView.string)
//      }
      
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      self.selectedRanges = textView.selectedRanges
      
    }
    
    
    // MARK: - NSTextLayoutManagerDelegate
    
    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                           textLayoutFragmentFor location: NSTextLocation,
                           in textElement: NSTextElement) -> NSTextLayoutFragment {
      let index = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)
      
      let layoutFragment = BubbleLayoutFragment(textElement: textElement, range: textElement.elementRange)
      layoutFragment.commentDepth = commentDepthValue!.uintValue
      
      if commentDepthValue != nil {
        return layoutFragment
      } else {
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
      }
    }
  }
}

