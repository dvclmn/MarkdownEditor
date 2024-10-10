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
    
//    var lastLineCount: Int = 0
    
    var selectedRanges: [NSValue] = []
//    var selections: [NSTextSelection] = []
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) { self.parent = parent }

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
    
    
    
    
    /// Counts the number of lines in the text view.
//    @MainActor
//    func currentLineCount() -> Int {
//      
//      guard let layoutManager = self.textView?.layoutManager,
//            let textContainer = self.textView?.textContainer else {
//        return 0
//      }
//      
//      let glyphRange = layoutManager.glyphRange(for: textContainer)
//      var lineCount = 0
//      
//      layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (_, _, _, _, _) in
//        lineCount += 1
//      }
//      
//      print("Current line count is: \(lineCount)")
//      
//      return lineCount
//    }
//    
  }
}
