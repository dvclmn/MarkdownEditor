//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

//import BaseHelpers
import SwiftUI

extension MarkdownEditor {

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  @MainActor
  public class Coordinator: NSObject, NSTextViewDelegate {
    let parent: MarkdownEditor

    var selectedRanges: [NSValue] = []

    public init(_ view: MarkdownEditor) {
      self.parent = view
    }

    /// This is for communicating changes from within AppKit, back to SwiftUI
        public func textDidChange(_ notification: Notification) {
          print("Ran `textDidChange`")
          guard let textView = notification.object as? NSTextView else { return }
          parent.text = textView.string
        }
    
        public func textViewDidChangeSelection(_ notification: Notification) {
          guard let textView = notification.object as? NSTextView else { return }
          self.selectedRanges = textView.selectedRanges
        }
    
  }
}
