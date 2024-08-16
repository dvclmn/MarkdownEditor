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
    
    let scrollView = MarkdownScrollView()

    let textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      configuration: configuration
    )
    textView.delegate = context.coordinator
    scrollView.documentView = textView
    
    textView.onInfoUpdate = { info in
      DispatchQueue.main.async { self.info(info) }
    }
    
    return scrollView
  }
  
  public func updateNSView(_ scrollView: MarkdownScrollView, context: Context) {
    
    guard let textView = scrollView.documentView as? MarkdownTextView else { return }

    
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

