
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
  
  public typealias TextInfo = (_ info: EditorInfo.Text) -> Void
  public typealias SelectionInfo = (_ info: EditorInfo.Selection) -> Void
  
  var textInfo: TextInfo
  var selectionInfo: SelectionInfo
//  var editorHeight: (_ height: CGFloat) -> Void
  
  public init(
    text: Binding<String>,
    textInfo: @escaping TextInfo = { _ in },
    selectionInfo: @escaping SelectionInfo = { _ in }
//    editorHeight: @escaping (_ height: CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.textInfo = textInfo
    self.selectionInfo = selectionInfo
//    self.editorHeight = editorHeight
  }
  
  public func makeNSView(context: Context) -> MarkdownTextView {
    
    let textView = MarkdownTextView()
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

    return textView
  }
  
  public func updateNSView(_ textView: MarkdownTextView, context: Context) {
    
    context.coordinator.updatingNSView = true
    
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
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
