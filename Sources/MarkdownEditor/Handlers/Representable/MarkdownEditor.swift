//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import OSLog
import BaseHelpers

public struct MarkdownEditor: NSViewRepresentable {
  
  public typealias TextInfo = (_ info: EditorInfo.Text) -> Void
  public typealias SelectionInfo = (_ info: EditorInfo.Selection) -> Void
  public typealias ScrollInfo = (_ info: EditorInfo.Scroll) -> Void
  public typealias EditorHeight = (_ height: CGFloat) -> Void
  
  @Binding var text: String
  var scrollOffsetIn: CGFloat
  var isShowingFrames: Bool
  var textInsets: CGFloat
  var textInfo: TextInfo
  var selectionInfo: SelectionInfo
  var scrollInfo: ScrollInfo
  var editorHeight: EditorHeight
  
  public init(
    text: Binding<String>,
    scrollOffsetIn: CGFloat,
    isShowingFrames: Bool = false,
    textInsets: CGFloat = 30,
    textInfo: @escaping TextInfo = { _ in },
    selectionInfo: @escaping SelectionInfo = { _ in },
    scrollInfo: @escaping ScrollInfo = { _ in },
    editorHeight: @escaping EditorHeight = { _ in }
  ) {
    self._text = text
    self.scrollOffsetIn = scrollOffsetIn
    self.isShowingFrames = isShowingFrames
    self.textInsets = textInsets
    self.textInfo = textInfo
    self.selectionInfo = selectionInfo
    self.scrollInfo = scrollInfo
    self.editorHeight = editorHeight
  }
  
  public func makeNSView(context: Context) -> MarkdownTextView {
    
    let textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      scrollOffset: scrollOffsetIn,
      isShowingFrames: isShowingFrames,
      textInsets: textInsets
    )
    textView.delegate = context.coordinator
    
    textView.onSelectionChange = { info in
      DispatchQueue.main.async { self.selectionInfo(info) }
    }
    
    textView.onTextChange = { info in
      DispatchQueue.main.async { self.textInfo(info) }
    }
    
    textView.onEditorHeightChange = { height in
      DispatchQueue.main.async { self.editorHeight(height) }
    }
    
    textView.onScrollChange = { info in
      DispatchQueue.main.async { self.scrollInfo(info) }
    }
    
    return textView
  }
  
  public func updateNSView(_ textView: MarkdownTextView, context: Context) {
    
    context.coordinator.parent = self
    context.coordinator.updatingNSView = true
    
//    textView.string ?= self.text
//    textView.scrollOffset ?= self.scrollOffsetIn
//    textView.isShowingFrames ?= self.isShowingFrames
//    

    if textView.string != self.text {
      textView.string = self.text
    }
    
    if textView.scrollOffset != self.scrollOffsetIn {
      textView.scrollOffset = self.scrollOffsetIn
    }
    
    if textView.isShowingFrames != self.isShowingFrames {
      textView.isShowingFrames = self.isShowingFrames
    }
    
    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

