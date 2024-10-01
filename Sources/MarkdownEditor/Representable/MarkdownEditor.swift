//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import OSLog
import BaseHelpers



public class EventEmitter<Event> {
  
  private var eventHandlers: [(Event) -> Void] = []
  
  public init() {}
  
  public func on(_ handler: @escaping (Event) -> Void) {
    eventHandlers.append(handler)
  }
  
  public func emit(_ event: Event) {
    print("Let's emit event: \(event)")
    eventHandlers.forEach { $0(event) }
  }
}

public enum SyntaxEvent {
  case wrap(Markdown.Syntax)
}

public struct MarkdownEditor: NSViewControllerRepresentable {
  
  public typealias NSViewControllerType = MarkdownViewController
  public typealias InfoUpdate = (_ info: EditorInfo) -> Void
  
  @Binding var text: String
  
//  var eventEmitter: EventEmitter<SyntaxEvent>
  
  var configuration: MarkdownEditorConfiguration
  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
//    eventEmitter: EventEmitter<SyntaxEvent>,
    configuration: MarkdownEditorConfiguration = .init(),
    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
//    self.eventEmitter = eventEmitter
    self.configuration = configuration
    self.info = info
  }
  
  public func makeNSViewController(context: Context) -> MarkdownViewController {
    
    let viewController = MarkdownViewController(
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
    
//    self.eventEmitter.on { event in
//      switch event {
//        case .wrap(let syntax):
//          textView.handleWrapping(for: syntax)
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
    
   
    textView.needsLayout = true
    textView.needsDisplay = true
    
    context.coordinator.updatingNSView = false
  }
}



