//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import OSLog
import BaseHelpers

public struct MarkdownEditor: NSViewControllerRepresentable {
  
  public typealias NSViewControllerType = MarkdownViewController
  
  public typealias InfoUpdate = (_ info: EditorInfo) -> Void
  
  @Binding var text: String
  @Binding var action: Markdown.SyntaxAction?
  var configuration: MarkdownEditorConfiguration
  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
    action: Binding<Markdown.SyntaxAction?>,
    configuration: MarkdownEditorConfiguration,
    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
    self._action = action
    self.configuration = configuration
    self.info = info
  }
  
  public func makeNSViewController(context: Context) -> MarkdownViewController {
    
    let viewController = MarkdownViewController(
      action: self.action,
      configuration: self.configuration
    )
    viewController.loadView()
    
    let textView = viewController.textView
    
    textView.string = text
    context.coordinator.textView = textView

    textView.delegate = context.coordinator
    textView.textLayoutManager?.delegate = context.coordinator
    
    textView.onInfoUpdate = { info in
      DispatchQueue.main.async {
        self.info(info)
      }
    }

    
    return viewController
  }
  
  public func updateNSViewController(_ nsView: MarkdownViewController, context: Context) {
    
    let textView = nsView.textView
    
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
    
    if textView.action != self.action {
      textView.action = self.action

    }
    
    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

