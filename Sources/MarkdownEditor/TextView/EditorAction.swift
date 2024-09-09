//
//  EditorAction.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 9/9/2024.
//

public extension Markdown {
  
  struct SyntaxAction: Sendable, Equatable {
    var syntax: Markdown.Syntax
    
    public init(
      syntax: Markdown.Syntax
    ) {
      self.syntax = syntax
    }
  }
}


extension Optional where Wrapped == Markdown.SyntaxAction {
  var summary: String {
    if let syntaxAction = self {
      return syntaxAction.syntax.name
    } else {
      return "nil"
    }
  }
}
