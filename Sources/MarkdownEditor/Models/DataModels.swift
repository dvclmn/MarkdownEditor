//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import AppKit

/// In keeping with Apple's convention, my idea of `Syntax` ==  their idea of `PresentationIntent.Kind`
/// My idea of `Structure` ==  their idea of `PresentationIntent` vs `InlinePresentationIntent`
///
/// I think `PresentationIntent.IntentType` exists because a *block* type of structure can contain other elements
/// Hence why `PresentationIntent` ships with this property `components`:
/// `public var components: [PresentationIntent.IntentType]`

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

extension PresentationIntent {
  static func list(style: Markdown.ListStyle) -> PresentationIntent {
    
    var kind: PresentationIntent.Kind
    
    switch style {
      case .ordered:
        kind = .orderedList
      case .unordered:
        kind = .unorderedList
    }
    
    return PresentationIntent(kind, identity: Markdown.Syntax.list(style: style).intentIdentity)
    
  }
}


extension InlinePresentationIntent {
  
  static var link: InlinePresentationIntent {
    var intent = InlinePresentationIntent()
    // Set some custom bit or combine with other intents as needed
    return intent
  }
  
  static var image: InlinePresentationIntent {
    var intent = InlinePresentationIntent()
    // Set some custom bit or combine with other intents as needed
    return intent
  }
  
  static var highlight: InlinePresentationIntent {
    var intent = InlinePresentationIntent()
    // Set some custom bit or combine with other intents as needed
    return intent
  }
  
}




/// Markdown
/// - Structure
///   - Inline (`InlinePresentationIntent`)
///   - Block (`PresentationIntent`)
///
/// - Kind


/// # Block
/// ## Native
/// `case blockQuote` //
/// `case codeBlock(languageHint: String?)` //
/// `case header(level: Int)` //
/// `case listItem(ordinal: Int)` //
/// `case orderedList` //
/// `case paragraph` //
/// `case table(columns: [PresentationIntent.TableColumn])` //
/// `case tableCell(columnIndex: Int)` //
/// `case tableHeaderRow` //
/// `case tableRow(rowIndex: Int)` //
/// `case thematicBreak` //
/// `case unorderedList` //
///
/// ## Custom
///
///
/// # Inline
/// ## Native
/// `static var code: InlinePresentationIntent` //
/// `static var emphasized: InlinePresentationIntent` // Aka italics
/// `static var lineBreak: InlinePresentationIntent` //
/// `static var softBreak: InlinePresentationIntent` //
/// `static var strikethrough: InlinePresentationIntent` //
/// `static var stronglyEmphasized: InlinePresentationIntent` //
/// `static var inlineHTML: InlinePresentationIntent` //
/// `static var blockHTML: InlinePresentationIntent` //
///
/// ## Custom
/// Depending on what Apple means by `emphasized` and `stronglyEmphasized`.
/// Will support both standard and 'alt' syntax types ("*" and "_").
///
/// - Bold
/// - Italic
/// - Bold Italic










/// `Markdown.Element` is generic over `MarkdownSyntax`, because Markdown's syntax types do not all share the same structure. Some, like **bold**, can be represented with two capture groups: `Regex<(Substring, Substring)>`. One group for the text that has been marked up ("bold"), and one group for the syntax characters themselves ("**" and "**").
///
/// Others, such as [links](http://link.com), require three capture groups: `Regex<(Substring, Substring, Substring)>`. One for the label, one for the link, and one for the syntax characters.
///


public enum LanguageHint: String, CaseIterable, Sendable {
  case swift
  case python
  case rust
  case go
  
  public var string: String {
    self.rawValue
  }
  
  public var intentIdentifier: Int {
    switch self {
      case .swift:
        1
      case .python:
        2
      case .rust:
        3
      case .go:
        4
    }
  }
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
