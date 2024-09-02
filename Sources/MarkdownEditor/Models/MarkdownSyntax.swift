//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//


import Foundation
import SwiftUI
import RegexBuilder

extension Markdown {
  
  public enum Syntax: Identifiable, Equatable, Hashable, Sendable {
    
    case heading(level: Int)
    
    case bold
    case italic
    case boldItalic
    
    case strikethrough
    case highlight
    case inlineCode
    
    case list(style: ListStyle)
    
    case horizontalRule
    
    /// To be supported in future versions:
    // case table(columns: [PresentationIntent.TableColumn])
    // case tableCell(columnIndex: Int)
    // case tableHeaderRow
    // case tableRow(rowIndex: Int
    
    case codeBlock
//    case codeBlock(language: LanguageHint?)
    case quoteBlock
    
    case link
    case image
    
    nonisolated public var id: String {
      self.name
    }
    
    public var name: String {
      
      switch self {
        case .heading(let level):
          let hashSymbols = String(repeating: "#", count: level)
          return "Heading \(hashSymbols)"
          
        case .bold: return "Bold"
        case .italic: return "Italic"
        case .boldItalic: return "Bold Italic"
        case .strikethrough: return "Strikethrough"
        case .highlight: return "Highlight"
        case .inlineCode: return "Inline code"
        case .list(let style): return "List \(style.name)"
        case .horizontalRule: return "Horizontal rule"
                  case .codeBlock: return "Code block"
          
//        case .codeBlock(let language):
//          if let language = language {
//            return "Code block (\(language)"
//          } else {
//            return "Code block"
//          }
        case .quoteBlock: return "Quote"
        case .link: return "Link"
        case .image: return "Image"
      }
      
    }
    
    public var layout: Markdown.Syntax.Layout {
      switch self {
        case .bold,
            .italic,
            .boldItalic,
            .strikethrough,
            .highlight,
            .inlineCode,
            .link,
            .image:
          return .inline
          
        case .heading,
            .quoteBlock,
            .horizontalRule,
            .list:
          return .block(.singleLine)
          
        case .codeBlock:
          return .block(.multiLine)
      }
    }
    
    
    public var syntaxBoundary: Markdown.Syntax.BoundaryStyle {
      switch self {
        case .heading, .list:
          return .leading
          
        case .bold,
            .italic,
            .boldItalic,
            .strikethrough,
            .highlight,
            .inlineCode,
            .quoteBlock:
          return .enclosed(.symmetrical)
          
        case .horizontalRule:
          return .none
          
        case .codeBlock:
          return .enclosed(.symmetrical)
          
        case .link, .image:
          return .enclosed(.asymmetrical)
      }
    }
    
    public var isWrappable: Bool {
      switch self {
        case .bold, .italic, .inlineCode: true
        default: false
      }
    }
    
    //    public var intent: any MarkdownIntent {
    //      switch self {
    //        case .heading(let level):
    //          BlockIntent(syntax: .heading(level: level), type: PresentationIntent(.header(level: level), identity: level))
    //        case .bold(let style):
    //          InlineIntent(syntax: .bold(style: style), type: .emphasized)
    //        case .italic(let style):
    //          InlineIntent(syntax: .italic(style: style), type: .emphasized)
    //        case .boldItalic(let style):
    //          InlineIntent(syntax: .boldItalic(style: style), type: .stronglyEmphasized)
    //        case .strikethrough:
    //          InlineIntent(syntax: .strikethrough, type: .strikethrough)
    //        case .highlight:
    //          InlineIntent(syntax: .highlight, type: .highlight)
    //        case .inlineCode:
    //          InlineIntent(syntax: .inlineCode, type: .code)
    //        case .list(let style):
    //          BlockIntent(syntax: .list(style: style), type: .list(style: style))
    //        case .horizontalRule:
    //          BlockIntent(syntax: .horizontalRule, type: PresentationIntent(.thematicBreak, identity: self.intentIdentity))
    //        case .codeBlock(let language):
    //          BlockIntent(syntax: self, type: PresentationIntent(.codeBlock(languageHint: language?.string), identity: self.intentIdentity))
    //        case .quoteBlock:
    //          BlockIntent(syntax: self, type: PresentationIntent(.blockQuote, identity: self.intentIdentity))
    //        case .link:
    //          InlineIntent(syntax: self, type: .link)
    //        case .image:
    //          InlineIntent(syntax: self, type: .image)
    //      }
    //    }
    
    public var hideSyntax: Bool {
      switch self {
        case .bold:
          true
        default:
          false
      }
    }
    
    //    public var syntaxCharacters: String {
    //      switch self {
    //        case .heading(let level):
    //
    //          let maxLevel = 6
    //
    //          /// Could also be written like this:
    //          /// ```
    //          /// var result = ""
    //          /// for _ in 1...min(level, 6) {
    //          ///   result += "#"
    //          /// }
    //          /// return result
    //          ///
    //          /// ```
    //          let levelWithLimit = min(level, maxLevel)
    //          return String(repeating: "#", count: levelWithLimit)
    //        case .bold(let style):
    //          switch style {
    //            case .asterisk: return "**"
    //            case .underscore: return "__"
    //          }
    //        case .italic(let style):
    //          switch style {
    //            case .asterisk: return "*"
    //            case .underscore: return "_"
    //          }
    //        case .boldItalic(let style):
    //          switch style {
    //            case .asterisk: return "***"
    //            case .underscore: return "___"
    //          }
    //        case .strikethrough: return "~~"
    //        case .highlight: return "=="
    //        case .inlineCode: return "`"
    //
    //          // TODO: Can improve implementation here
    //        case .list: return "- "
    //        case .horizontalRule: return "---"
    //        case .codeBlock(let language): return "```\(language?.string ?? "")"
    //        case .quoteBlock: return "> "
    //        case .link: return "?"
    //        case .image: return "?"
    //      }
    //    }
    
    //    public var syntaxCharacterCount: Int {
    //      self.syntaxCharacters.count
    //    }
    //
    public var shortcut: KeyboardShortcut? {
      switch self {
          
        case .bold:
            .init("b", modifiers: [.command])
        case .italic:
            .init("i", modifiers: [.command])
        case .boldItalic:
            .init("b", modifiers: [.command, .shift])
        case .strikethrough:
            .init("u", modifiers: [.command])
        case .inlineCode:
            .init("c", modifiers: [.command, .option])
        case .codeBlock:
            .init("k", modifiers: [.command, .shift])
        default:
          nil
      }
    }
    
  }
}


public extension Markdown.Syntax {
  enum EmphasisStyle: Sendable {
    case asterisk
    case underscore
  }
  
  enum ListStyle: Sendable {
    case ordered
    case unordered
    
    public var name: String {
      switch self {
        case .ordered:
          "Ordered"
        case .unordered:
          "Unordered"
      }
    }
  }
  
  enum Layout {
    case inline
    case block(BlockType)
    
    public enum BlockType {
      
      /// I think i'll keep this distinction between single- and multi-line
      /// For instance, adding an explicit line break within a code block is valid,
      /// and does not 'interrupt' or 'break out of' the block.
      ///
      /// Whereas doing the same in a heading, *does* break out of the heading.
      ///
      /// I think encapsulating that distinction is important.
      ///
      case singleLine
      case multiLine
    }
  }
  
  enum BoundaryStyle {
    
    /// E.g. `# Headings`
    ///
    case leading
    
    /// E.g. Symmetrical: `**bold**`
    /// E.g. Asymmetrical: `[label](http://link.url)`
    ///
    case enclosed(EnclosedType)
    
    /// E.g. Horizontal rule
    ///
    case none
    
    public enum EnclosedType {
      case symmetrical
      case asymmetrical
    }
  }
}



extension Markdown.Syntax {
  
  
  static public var allCases: [Markdown.Syntax] {
    return [
      .heading(level: 1),
      .heading(level: 2),
      .heading(level: 3),
      .heading(level: 4),
      .heading(level: 5),
      .heading(level: 6),
      
        .bold,
      .italic,
      .boldItalic,

        .strikethrough,
      .highlight,
      .inlineCode,
      
        .list(style: .ordered),
      .horizontalRule,
      .codeBlock,
      .quoteBlock,
      .link,
      .image
    ]
  }
  
  static public var testCases: [Markdown.Syntax] {
    return [
      .heading(level: 1),
      .heading(level: 2),
      .heading(level: 3),
      .heading(level: 4),
      .heading(level: 5),
      .heading(level: 6),
      
        .bold,
      .italic,
      .boldItalic,
      
        .strikethrough,
      .highlight,
      .inlineCode,
      
        .list(style: .ordered),
      .horizontalRule,
      .codeBlock,
      .quoteBlock,
      .link,
      .image
    ]
  }
  
}
