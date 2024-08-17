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
  
  public func makeNSView(context: Context) -> MarkdownScrollView {
    
    let scrollView = MarkdownScrollView(frame: .zero)
    
    scrollView.textView.delegate = context.coordinator
    scrollView.textView.configuration = configuration
    
    scrollView.textView.onInfoUpdate = { info in
      DispatchQueue.main.async { self.info(info) }
    }
    
    return scrollView
  }
  
  public func updateNSView(_ scrollView: MarkdownScrollView, context: Context) {
    
    guard let textView = scrollView.textView else { return }
    
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

