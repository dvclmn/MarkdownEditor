//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit


public protocol MarkdownElement: Equatable {
  associatedtype Syntax: MarkdownSyntax
  var type: Syntax { get set }
  var range: NSTextRange { get set }
}

public typealias AnyMarkdownElement = (any MarkdownElement)

public struct Markdown {
  
  public struct SingleCaptureElement: MarkdownElement {
    public var type: SingleCaptureSyntax
    public var range: NSTextRange
  }
  
  public struct DoubleCaptureElement: MarkdownElement {
    public var type: DoubleCaptureSyntax
    public var range: NSTextRange
  }
  
 
}




/// `Markdown.Element` is generic over `MarkdownSyntax`, because Markdown's syntax types do not all share the same structure. Some, like **bold**, can be represented with two capture groups: `Regex<(Substring, Substring)>`. One group for the text that has been marked up ("bold"), and one group for the syntax characters themselves ("**" and "**").
///
/// Others, such as [links](http://link.com), require three capture groups: `Regex<(Substring, Substring, Substring)>`. One for the label, one for the link, and one for the syntax characters.
///


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
