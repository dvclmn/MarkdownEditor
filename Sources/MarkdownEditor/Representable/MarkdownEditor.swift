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
  var configuration: MarkdownEditorConfiguration
  var action: MarkdownAction?
  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
    configuration: MarkdownEditorConfiguration,
    action: MarkdownAction? = nil,
    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.action = action
    self.info = info
  }
  
  public func makeNSViewController(context: Context) -> MarkdownViewController {
    
    let viewController = MarkdownViewController(configuration: self.configuration)
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
//    viewController.actionHandler = { action in
//      DispatchQueue.main.async {
//        print("Received the action from SwiftUI, passing it to AppKit")
//      }
//    }

    
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
    
    if self.action != nsView.actionHandler {
      textView.configuration = self.configuration
      textView.applyConfiguration()
    }

    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}

