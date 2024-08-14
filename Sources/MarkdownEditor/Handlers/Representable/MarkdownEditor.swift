
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
  
  public typealias TextInfo = (_ info: EditorInfo.Text) -> Void
  public typealias SelectionInfo = (_ info: EditorInfo.Selection) -> Void
  public typealias EditorHeight = (_ height: CGFloat) -> Void
  
  @Binding var text: String
  var isShowingFrames: Bool
  var textInsets: CGFloat
  var textInfo: TextInfo
  var selectionInfo: SelectionInfo
  var editorHeight: EditorHeight
  
  public init(
    text: Binding<String>,
    isShowingFrames: Bool = false,
    textInsets: CGFloat = 30,
    textInfo: @escaping TextInfo = { _ in },
    selectionInfo: @escaping SelectionInfo = { _ in },
    editorHeight: @escaping EditorHeight = { _ in }
  ) {
    self._text = text
    self.isShowingFrames = isShowingFrames
    self.textInsets = textInsets
    self.textInfo = textInfo
    self.selectionInfo = selectionInfo
    self.editorHeight = editorHeight
  }
  
  public func makeNSView(context: Context) -> NSScrollView {
    
    let scrollView = NSScrollView()
    
    let textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      isShowingFrames: isShowingFrames,
      textInsets: textInsets
    )
    textView.delegate = context.coordinator
    
    scrollView.documentView = textView
    
    textView.onSelectionChange = { info in
      DispatchQueue.main.async { self.selectionInfo(info) }
    }
    
    textView.onTextChange = { info in
      DispatchQueue.main.async { self.textInfo(info) }
    }
    
    textView.onEditorHeightChange = { height in
      DispatchQueue.main.async { self.editorHeight(height) }
    }
    
    
    return scrollView
  }
  
  public func updateNSView(_ scrollView: NSScrollView, context: Context) {
    
    context.coordinator.parent = self
    
    let textView = scrollView.documentView as! MarkdownTextView
    
    context.coordinator.updatingNSView = true
    
    if textView.string != self.text {
      textView.string = self.text
    }
    
    if textView.isShowingFrames != self.isShowingFrames {
      textView.isShowingFrames = self.isShowingFrames
    }
    
    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
