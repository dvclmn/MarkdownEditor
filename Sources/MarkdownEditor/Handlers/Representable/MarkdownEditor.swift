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
  var configuration: EditorConfiguration
  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
    configuration: EditorConfiguration = EditorConfiguration(),
    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.info = info
  }
  
  public func makeNSView(context: Context) -> MarkdownContainerView {
    
    let nsView = MarkdownContainerView(frame: .zero)
    
    nsView.scrollView.textView.delegate = context.coordinator
    nsView.scrollView.textView.textLayoutManager?.delegate = context.coordinator
    nsView.scrollView.textView.configuration = configuration
    
    nsView.scrollView.textView.onInfoUpdate = { info in
      DispatchQueue.main.async { self.info(info) }
    }
    
    return nsView
  }
  
  public func updateNSView(_ nsView: MarkdownContainerView, context: Context) {
    
    guard let textView = nsView.scrollView.textView else { return }
    
    context.coordinator.parent = self
    
    context.coordinator.updatingNSView = true

    if textView.string != self.text {
      textView.string = self.text
    }
    
    if textView.configuration != self.configuration {
      textView.configuration = self.configuration
    }
    
    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

