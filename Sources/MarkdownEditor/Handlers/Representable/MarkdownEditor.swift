
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
  @Binding var editorHeight: CGFloat
  var isShowingFrames: Bool
  
  public typealias TextInfo = (_ info: EditorInfo.Text) -> Void
  public typealias SelectionInfo = (_ info: EditorInfo.Selection) -> Void
  
  var textInfo: TextInfo
  var selectionInfo: SelectionInfo
  
  public init(
    text: Binding<String>,
    editorHeight: Binding<CGFloat>,
    isShowingFrames: Bool = false,
    textInfo: @escaping TextInfo = { _ in },
    selectionInfo: @escaping SelectionInfo = { _ in }
  ) {
    self._text = text
    self._editorHeight = editorHeight
    self.isShowingFrames = isShowingFrames
    self.textInfo = textInfo
    self.selectionInfo = selectionInfo
  }
  
  public func makeNSView(context: Context) -> MarkdownTextView {
    
    
    
    let textView = MarkdownTextView(
      isShowingFrames: self.isShowingFrames
    )
    textView.delegate = context.coordinator
    
    textView.onSelectionChange = { info in
      DispatchQueue.main.async {
        self.selectionInfo(info)
      }
    }
    
    textView.onTextChange = { info in
      DispatchQueue.main.async {
        self.textInfo(info)
      }
    }
    
//    self.editorHeight = textView.editorHeight
    
    return textView
  }
  
  public func updateNSView(_ textView: MarkdownTextView, context: Context) {
    
    context.coordinator.updatingNSView = true
    
    if textView.string != self.text {
      textView.string = self.text
//      self.editorHeight = textView.editorHeight
    }
  
    context.coordinator.updatingNSView = false
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
