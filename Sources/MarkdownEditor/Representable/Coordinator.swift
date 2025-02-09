//
//  Coordinator.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import BaseHelpers
import MarkdownModels
import SwiftUI

extension MarkdownEditor {

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public class Coordinator: NSObject, NSTextViewDelegate {
    let parent: MarkdownEditor

    var selectedRanges: [NSValue] = []

    public init(_ view: MarkdownEditor) {
      self.parent = view
    }
    public func textDidChange(_ notification: Notification) {
      print("Ran `textDidChange`")
      guard let textView = notification.object as? NSTextView else { return }
      parent.text = textView.string
    }  // END text did change

    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView
      else { return }
      self.selectedRanges = textView.selectedRanges
    }
  }
}

