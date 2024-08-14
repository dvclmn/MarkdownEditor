
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
  
  @Binding var text: String
  var metrics: (_ metrics: String) -> Void
  var editorHeight: (_ height: CGFloat) -> Void
  
  public init(
    text: Binding<String>,
    metrics: @escaping (_ metrics: String) -> Void = { _ in },
    editorHeight: @escaping (_ height: CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.metrics = metrics
    self.editorHeight = editorHeight
  }
  
  
  public func makeNSView(context: Context) -> MarkdownView {
    
    os_log("Made `ScrollableTextView` with `makeNSView`")
    
    let nsView = MarkdownView()
    nsView.delegate = context.coordinator
    
    
    
    self.sendOutMetrics(for: nsView)
    self.sendOutEditorHeight(for: nsView)
    
    return nsView
  }
  
  public func updateNSView(_ nsView: MarkdownView, context: Context) {
    
    context.coordinator.updatingNSView = true
    
    
    let textView = nsView.textView
    
    
    
    
    
    if textView.string != self.text {
      
      textView.string = self.text
      
      
      
    }
    
    
    //    let typingAttributes = textView.typingAttributes
    //
    //    if storage.attributedString?.string != self.text {
    //
    //      storage.performEditingTransaction {
    //        storage.textStorage?.replaceCharacters(in: storage.documentRange, with: self.text)
    //      }
    //
    //    }
    
    //    os_log("`updateNSView`. `typingAttributes`: \(typingAttributes)")
    
    //    let highlightedText = MarkdownEditor.getHighlightedText(
    //      text: self.text
    //    )
    
    //    nsView.attributedText = highlightedText
    
    //    nsView.selectedRanges = context.coordinator.selectedRanges
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
  
  @MainActor
  private func sendOutMetrics(for nsView: MarkdownView) {

    let textView = nsView.textView
    let string = textView.string
    let exampleSyntax = MarkdownSyntax.inlineCode
    
//    guard let documentRange = textView.textLayoutManager?.documentRange else { return }
    
//    let elements = textView.textContentStorage?.textElements(for: documentRange)
    
//    textView.textLayoutManager

    DispatchQueue.main.async {
      
      
      let metrics = nsView.textView.parser.elements.debugDescription
      self.metrics(metrics)
    }
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  
}

public extension MarkdownEditor {
  final class Coordinator: NSObject, NSTextContentStorageDelegate {
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
    
    @MainActor
    public func textDidBeginEditing(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else {
        return
      }
      
      parent.text = textView.string
      
    }
    //
    //    @MainActor public func textDidChange(_ notification: Notification) {
    //      guard let textView = notification.object as? NSTextView,
    //            let markdownView = textView.superview?.superview as? MarkdownView
    //      else { return }
    //
    //
    //      if let string = markdownView.textContentStorage.attributedString?.string {
    //        parent.text = string
    //      }
    //      selectedRanges = textView.selectedRanges
    //
    //      self.parent.editorHeight(textView.frame.height)
    //
    //    }
    //
    //    @MainActor
    //    public func textViewDidChangeSelection(_ notification: Notification) {
    //      guard let textView = notification.object as? NSTextView,
    //            !updatingNSView,
    //            let ranges = textView.selectedRanges as? [NSRange]
    //      else { return }
    //      selectedRanges = textView.selectedRanges
    //      DispatchQueue.main.async {
    //        self.parent.onSelectionChange(ranges)
    //      }
    //    }
    //
    //    @MainActor
    //    public func textDidEndEditing(_ notification: Notification) {
    //      guard let textView = notification.object as? NSTextView else {
    //        return
    //      }
    //
    //      parent.text = textView.string
    //      parent.onCommit()
    //    }
  }
}
