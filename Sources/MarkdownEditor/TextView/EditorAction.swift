//
//  EditorAction.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/9/2024.
//


public typealias MarkdownAction = (_ action: Markdown.SyntaxAction) -> Void


public extension Markdown {
  
  struct SyntaxAction: Sendable {
    var syntax: Markdown.Syntax
    
    public init(syntax: Markdown.Syntax) {
      self.syntax = syntax
    }
  }
}

