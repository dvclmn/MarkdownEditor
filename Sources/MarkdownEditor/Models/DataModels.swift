//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit


public protocol MarkdownElement: Equatable {
  
  associatedtype Syntax
  var type: Syntax { get set }
  var range: NSTextRange { get set }
}

public protocol MarkdownSyntax: Equatable {
  associatedtype RegexOutput
  var regex: Regex<RegexOutput> { get }
  var name: String { get }
  var contentAttributes: AttributeSet { get }
  var syntaxAttributes: AttributeSet { get }
}

public struct Markdown {
  
  /// `Markdown.Element` is generic over `MarkdownSyntax`, because Markdown's syntax types do not all share the same structure. Some, like **bold**, can be represented with two capture groups: `Regex<(Substring, Substring)>`. One group for the text that has been marked up ("bold"), and one group for the syntax characters themselves ("**" and "**").
  ///
  /// Others, such as [links](http://link.com), require three capture groups: `Regex<(Substring, Substring, Substring)>`. One for the label, one for the link, and one for the syntax characters.
  ///
//  public struct Element<S: MarkdownSyntax>: Equatable {
//    public var type: S
//    public var range: NSTextRange
//    
//    public static func == (lhs: Markdown.Element<S>, rhs: Markdown.Element<S>) -> Bool {
//      return lhs.type == rhs.type && lhs.range == rhs.range
//    }
//  }
  
  public struct SingleCaptureElement: MarkdownElement {
    
    public typealias Syntax = SingleCaptureSyntax
    public var type: Syntax
    public var range: NSTextRange
    
  }
  
  public struct DoubleCaptureElement: MarkdownElement {
    
    public typealias Syntax = DoubleCaptureSyntax
    public var type: Syntax
    public var range: NSTextRange
    
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
