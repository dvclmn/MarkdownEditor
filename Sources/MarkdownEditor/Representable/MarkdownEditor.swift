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
  
  public func makeNSView(context: Context) -> MarkdownScrollView {
    
    let viewController = MarkdownViewController(configuration: self.configuration)
    viewController.loadView()
    
    let textView = viewController.textView
    
    textView.string = text
    context.coordinator.textView = textView

    textView.delegate = context.coordinator
    textView.textLayoutManager?.delegate = context.coordinator
    
    
    textView.onInfoUpdate = { info in
      DispatchQueue.main.async { self.info(info) }
    }
    
    return viewController.view as! MarkdownScrollView
  }
  
  public func updateNSView(_ scrollView: MarkdownScrollView, context: Context) {
    
    let textView = scrollView.documentView as! MarkdownTextView
    
    context.coordinator.parent = self
    context.coordinator.textView = textView
    
    context.coordinator.updatingNSView = true
    
    if textView.string != self.text {
      textView.string = self.text
    }
    
    if textView.configuration != self.configuration {
      textView.configuration = self.configuration
      textView.applyConfiguration()
    }

    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

