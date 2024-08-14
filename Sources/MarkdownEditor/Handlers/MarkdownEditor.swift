
/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020
 *  https://twitter.com/tholanda
 *
 *  Modified by Kyle Nazario 2020
 *
 *  MIT license
 */

import SwiftUI
import OSLog

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
  
  public func makeNSView(context: Context) -> MarkdownTextView {
    
    let textView = MarkdownTextView()
    textView.delegate = context.coordinator
    
    self.sendOutMetrics(for: textView)
    self.sendOutEditorHeight(for: textView)
    
    return textView
  }
  
  public func updateNSView(_ textView: MarkdownTextView, context: Context) {
    
    context.coordinator.updatingNSView = true
    
    if textView.string != self.text {
      textView.string = self.text
      
      textView.assembleMetrics()
      
      //      self.sendOutMetrics(for: nsView)
      
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
  private func sendOutEditorHeight(for textView: MarkdownTextView) {
    DispatchQueue.main.async {
      let height = textView.intrinsicContentSize.height + 80
      textView.invalidateIntrinsicContentSize()
      self.editorHeight(height)
    }
  }
  
  @MainActor
  private func sendOutMetrics(for textView: MarkdownTextView) {
    
    
    DispatchQueue.main.async {
      self.metrics(textView.editorMetrics)
    }
    //    let exampleSyntax = MarkdownSyntax.inlineCode
    //
    //    guard let documentRange = textView.textLayoutManager?.documentRange else { return }
    //
    //    var textElementCount: Int = 0
    //
    //    textView.textLayoutManager?.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
    //      textElementCount += 1
    //      return true
    //    })
    //
    //    DispatchQueue.main.async {
    //
    //      let finalMetrics: String = """
    //      Editor height: \(textView.intrinsicContentSize.height.description)
    //      Character count: \(textView.string.count)
    //      Text elements: \(textElementCount.description)
    //      Document range: \(documentRange.description)
    //      """
    //
    //      self.metrics(finalMetrics)
    //    }
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  
}

public extension MarkdownEditor {
  final class Coordinator: NSObject, NSTextViewDelegate, NSTextContentStorageDelegate {
    var parent: MarkdownEditor
    var selectedRanges: [NSValue] = []
    var updatingNSView = false
    
    init(_ parent: MarkdownEditor) {
      self.parent = parent
    }
    
    //
    @MainActor public func textDidChange(_ notification: Notification) {
      
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      parent.text = textView.string
      textView.assembleMetrics()
      
      //      if self.parent.text != textView.string {
      //        parent.text = textView.string
      //      }
      //      if self.selectedRanges != textView.selectedRanges {
      //        self.selectedRanges = textView.selectedRanges
      //      }
      //
      //      self.parent.sendOutEditorHeight(for: nsView)
      //      self.parent.sendOutMetrics(for: nsView)
      
      
      
    }
    
    //    @objc func metricsDidChange(_ notification: Notification) {
    //      guard let textView = notification.object as? MarkdownTextView,
    //            let nsView = textView.superview as? MarkdownView else { return }
    //
    //      nsView.editorMetrics = textView.editorMetrics
    //      parent.metrics(nsView.editorMetrics)
    //    }
    
    
    
    //
    @MainActor
    public func textViewDidChangeSelection(_ notification: Notification) {
      guard let textView = notification.object as? MarkdownTextView,
            !updatingNSView
      else { return }
      
      selectedRanges = textView.selectedRanges
      
      
    }
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


//extension MarkdownEditor {
//  func setupScrollView(for scrollView: NSScrollView) {
//    
//    scrollView.hasVerticalScroller = true
//    scrollView.hasHorizontalScroller = false
//    scrollView.autohidesScrollers = true
//    scrollView.borderType = .noBorder
//    scrollView.translatesAutoresizingMaskIntoConstraints = false
//    scrollView.drawsBackground = false
//    
//    NSLayoutConstraint.activate([
//      scrollView.topAnchor.constraint(equalTo: .),
//      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
//      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
//    ])
//    
//  }
//}
