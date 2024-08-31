//
//  DataModel.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI
import RegexBuilder




extension Regex<Substring>: @unchecked @retroactive Sendable {
  
}

extension NSTextRange: @unchecked @retroactive Sendable {
  
}

extension NSParagraphStyle: @unchecked @retroactive Sendable {
  
}

public typealias MarkdownRegexOutput = Regex<Substring>

public struct Markdown {

}


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



