//
//  EventEmitter.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 1/12/2024.
//

import Foundation

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
