//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

/// In keeping with Apple's convention, my idea of `Syntax` ==  their idea of `PresentationIntent.Kind`
/// My idea of `Structure` ==  their idea of `PresentationIntent` vs `InlinePresentationIntent`
///
/// I think `PresentationIntent.IntentType` exists because a *block* type of structure can contain other elements
/// Hence why `PresentationIntent` ships with this property `components`:
/// `public var components: [PresentationIntent.IntentType]`

//public protocol MarkdownElement: Equatable {
//  var type: Markdown.Syntax { get set }
//  var range: NSTextRange { get set }
//}
//
//public typealias AnyMarkdownElement = (any MarkdownElement)



// TODO: Shortcut to move lines up aND DOWN

//public protocol MarkdownSyntax: Equatable, Sendable {
//
//  associatedtype RegexOutput
//  associatedtype Structure
//
//  var name: String { get }
//  var regex: Regex<RegexOutput> { get }
//  var structure: Structure { get }
//  var contentAttributes: AttributeSet { get }
//  var syntaxAttributes: AttributeSet { get }
//}

public typealias MarkdownRegexOutput = Regex<Substring>

public protocol MarkdownIntent: Equatable, Sendable {
  associatedtype StructureType
  var syntax: Markdown.Syntax { get }
  var type: StructureType { get }
}

//public typealias AnyMarkdownIntent = (any MarkdownIntent)

public extension Markdown {
  
  /// E.g. code blocks, quote blocks, headings
  ///
  struct BlockIntent: MarkdownIntent {
    public var syntax: Markdown.Syntax
    public var type: PresentationIntent
  }
  
  /// E.g. bold, italic, strikethrough
  ///
  struct InlineIntent: MarkdownIntent {
    public var syntax: Markdown.Syntax
    public var type: InlinePresentationIntent
  }
  
  
  /// Usage:
  /// ```
  /// let link = MarkdownInlineElement(
  ///   intent: .link(url: URL(string: "https://example.com")!, title: "Example"),
  ///   range: NSRange(location: 0, length: 10),
  ///   additionalInfo: ["url": URL(string: "https://example.com")!, "title": "Example"]
  /// )
  ///
  /// let image = MarkdownInlineElement(
  ///   intent: .image(url: URL(string: "https://example.com/image.jpg")!, altText: "An example /// image", title: "Example"),
  ///   range: NSRange(location: 0, length: 20),
  ///   additionalInfo: ["url": URL(string: "https://example.com/image.jpg")!, "altText": "An /// example image", "title": "Example"]
  /// )
  /// ```
  /// My approach atm is to write up a struct will all the propreties I may need, then i'll work out how to seperate it out logically
  
  
  
}



public struct Markdown {

  struct Element: Sendable {
    var type: Markdown.Syntax
    nonisolated(unsafe) var fullRange: NSTextRange
    
    
  }
  
}

extension PresentationIntent {
  static func list(style: Markdown.Syntax.ListStyle) -> PresentationIntent {
    
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


public struct MarkdownEditorConfiguration: Sendable {
  public var fontSize: Double
  public var fontWeight: NSFont.Weight
  public var insertionPointColour: Color
  public var codeColour: Color
  public var paddingX: Double
  public var paddingY: Double
  
  public init(
    fontSize: Double = MarkdownDefaults.fontSize,
    fontWeight: NSFont.Weight = MarkdownDefaults.fontWeight,
    insertionPointColour: Color = .blue,
    codeColour: Color = .primary.opacity(0.7),
    paddingX: Double = MarkdownDefaults.paddingX,
    paddingY: Double = MarkdownDefaults.paddingY
  ) {
    self.fontSize = fontSize
    self.fontWeight = fontWeight
    self.insertionPointColour = insertionPointColour
    self.codeColour = codeColour
    self.paddingX = paddingX
    self.paddingY = paddingY
  }
}



public struct MarkdownDefaults: Sendable {
  
  @MainActor public static let defaultFont =               NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: MarkdownDefaults.fontWeight)
  public static let fontSize:                 Double = 15
  public static let fontWeight:               NSFont.Weight = .regular
  public static let fontOpacity:              Double = 0.85
  
  public static let headerSyntaxSize:         Double = 20
  
  public static let fontSizeMono:             Double = 14.5
  
  public static let syntaxAlpha:              Double = 0.3
  public static let backgroundInlineCode:     Double = 0.2
  public static let backgroundCodeBlock:      Double = 0.4
  
  public static let lineSpacing:              Double = 6
  public static let paragraphSpacing:         Double = 0
  
  public static let paddingX: Double = 30
  public static let paddingY: Double = 30
}


