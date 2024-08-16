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
  
  public typealias InfoUpdate = (_ info: EditorInfo) -> Void
  
  @Binding var text: String
  var scrollOffsetIn: CGFloat
  var configuration: EditorConfiguration
  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
    scrollOffsetIn: CGFloat,
    configuration: EditorConfiguration = EditorConfiguration(),
    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
    self.scrollOffsetIn = scrollOffsetIn
    self.configuration = configuration
    self.info = info
  }
  
  public func makeNSView(context: Context) -> MarkdownTextView {
    
    let textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      scrollOffset: scrollOffsetIn,
      configuration: configuration
    )
    textView.delegate = context.coordinator
    
    textView.onInfoUpdate = { info in
      DispatchQueue.main.async { self.info(info) }
    }
    
    return textView
  }
  
  public func updateNSView(_ textView: MarkdownTextView, context: Context) {
    
    context.coordinator.parent = self
    
    context.coordinator.updatingNSView = true

    if textView.string != self.text {
      textView.string = self.text
    }
    
    if textView.scrollOffset != self.scrollOffsetIn {
      textView.scrollOffset = self.scrollOffsetIn
    }
    
    if textView.configuration != self.configuration {
      textView.configuration = self.configuration
    }
    
    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

