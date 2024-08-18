//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit


protocol Markdownable: Equatable {
  var type: Markdown.Syntax { get set }
  var range: NSTextRange { get set }
}

public struct Markdown {
  
  public struct Element: Markdownable {
    var type: Markdown.Syntax
    var range: NSTextRange
  }
  
  public enum Structure {
    case block
    case line
    case inline
  }

}





public enum Language: String, CaseIterable {
  case swift
  case python
  case rust
  case go
}

public struct EditorConfiguration: Sendable, Equatable {
  var isShowingFrames: Bool
  var insets: CGFloat
  
  public init(
    isShowingFrames: Bool = false,
    insets: CGFloat = 20
  ) {
    self.isShowingFrames = isShowingFrames
    self.insets = insets
  }
}



//class MarkdownElement: NSTextElement {
//  var range: NSTextRange
//  let syntax: Markdown.Syntax
//  var languageIdentifier: Language?
//  
//  init(
//    _ textContentManager: NSTextContentManager,
//    range: NSTextRange,
//    syntax: Markdown.Syntax,
//    languageIdentifier: Language? = nil
//  ) {
//    self.range = range
//    self.syntax = syntax
//    self.languageIdentifier = languageIdentifier
//    super.init(textContentManager: textContentManager)
//  }
//}

