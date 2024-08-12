
/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020
 *  https://twitter.com/tholanda
 *
 *  Modified by Kyle Nazario 2020
 *
 *  MIT license
 */

import AppKit
import SwiftUI
import OSLog
//import Shortcuts

public struct MarkdownEditor: NSViewRepresentable {
  @Binding var text: String {
    didSet {
      onTextChange(text)
    }
  }

  var onEditingChanged: () -> Void
  var onCommit: () -> Void
  var onTextChange: (_ editorContent: String) -> Void
  var onSelectionChange: ([NSRange]) -> Void
  
  var editorHeight: (CGFloat) -> Void
  
  public init(
    text: Binding<String>,
    onEditingChanged: @escaping () -> Void = {},
    onCommit: @escaping () -> Void = {},
    onTextChange: @escaping (_ editorContent: String) -> Void = {_ in},
    onSelectionChange: @escaping ([NSRange]) -> Void = {_ in},
    editorHeight: @escaping (CGFloat) -> Void = {_ in}
  ) {
    self._text = text
    self.onEditingChanged = onEditingChanged
    self.onCommit = onCommit
    self.onTextChange = onTextChange
    self.onSelectionChange = onSelectionChange
    self.editorHeight = editorHeight
    
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func makeNSView(context: Context) -> MarkdownView {
    
    os_log("Made `ScrollableTextView` with `makeNSView`")
    
    let nsView = MarkdownView()
    nsView.delegate = context.coordinator
    
    self.sendOutEditorHeight(for: nsView)

    return nsView
  }
  
  public func updateNSView(_ nsView: MarkdownView, context: Context) {
    
    context.coordinator.updatingNSView = true
    
//    let textView = nsView.textView
    
//    let typingAttributes = textView.typingAttributes
    
//    os_log("`updateNSView`. `typingAttributes`: \(typingAttributes)")
    
//    let highlightedText = MarkdownEditor.getHighlightedText(
//      text: text
//    )
    
    nsView.attributedText = NSAttributedString(string: self.text)
    
    nsView.selectedRanges = context.coordinator.selectedRanges
//    nsView.textView.typingAttributes = typingAttributes
    
    context.coordinator.updatingNSView = false
  }
  
  @MainActor
  private func sendOutEditorHeight(for nsView: MarkdownView) {

    DispatchQueue.main.async {
      let height = nsView.textView.intrinsicContentSize.height + 80
      nsView.textView.invalidateIntrinsicContentSize()
      self.editorHeight(height)
    }
    
  }
  
}

public extension MarkdownEditor {
  final class Coordinator: NSObject, NSTextViewDelegate {
    var parent: MarkdownEditor
    var selectedRanges: [NSValue] = []
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) {
      self.parent = parent
    }
    
    public func textView(
      _ textView: NSTextView,
      shouldChangeTextIn affectedCharRange: NSRange,
      replacementString: String?
    ) -> Bool {
      return true
    }
    
    public func textDidBeginEditing(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else {
        return
      }
      
      parent.text = textView.string
      parent.onEditingChanged()
    }
    
    public func textDidChange(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else { return }
//      let content = String(textView.textStorage?.string ?? "")
      
      if let string = textView.textContentStorage?.attributedString?.string {
        parent.text = string
      }
      selectedRanges = textView.selectedRanges
      
      self.parent.editorHeight(textView.frame.height)
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView,
            !updatingNSView,
            let ranges = textView.selectedRanges as? [NSRange]
      else { return }
      selectedRanges = textView.selectedRanges
      DispatchQueue.main.async {
        self.parent.onSelectionChange(ranges)
      }
    }
    
    public func textDidEndEditing(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else {
        return
      }
      
      parent.text = textView.string
      parent.onCommit()
    }
  }
}

//public extension MarkdownEditor {
//  
//  func onCommit(_ callback: @escaping () -> Void) -> Self {
//    var editor = self
//    editor.onCommit = callback
//    return editor
//  }
//  
//  func onEditingChanged(_ callback: @escaping () -> Void) -> Self {
//    var editor = self
//    editor.onEditingChanged = callback
//    return editor
//  }
//  
//  func onTextChange(_ callback: @escaping (_ editorContent: String) -> Void) -> Self {
//    var editor = self
//    editor.onTextChange = callback
//    return editor
//  }
//  
//  func onSelectionChange(_ callback: @escaping ([NSRange]) -> Void) -> Self {
//    var editor = self
//    editor.onSelectionChange = callback
//    return editor
//  }
//  
//  func onSelectionChange(_ callback: @escaping (_ selectedRange: NSRange) -> Void) -> Self {
//    var editor = self
//    editor.onSelectionChange = { ranges in
//      guard let range = ranges.first else { return }
//      callback(range)
//    }
//    return editor
//  }
//}
//
