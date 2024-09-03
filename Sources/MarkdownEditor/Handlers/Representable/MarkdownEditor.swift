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
  var configuration: MarkdownEditorConfiguration
  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
    configuration: MarkdownEditorConfiguration,
    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.info = info
  }
  
  public func makeNSView(context: Context) -> MarkdownContainerView {
    
    let nsView = MarkdownContainerView(frame: .zero, configuration: self.configuration)
    
    let textView = nsView.textView
    
    textView.delegate = context.coordinator
    textView.textLayoutManager?.delegate = context.coordinator
    
    context.coordinator.textView = textView
    
    textView.onInfoUpdate = { info in
      DispatchQueue.main.async { self.info(info) }
    }
    
    return nsView
  }
  
  public func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
    
    let textView = nsView.textView
    
    context.coordinator.parent = self
    context.coordinator.textView = textView
    
    context.coordinator.updatingNSView = true
    
    if textView.string != self.text {
      textView.string = self.text
    }
    
    if textView.configuration != self.configuration {
      textView.configuration = self.configuration
      nsView.textView.applyConfiguration()
    }

    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

