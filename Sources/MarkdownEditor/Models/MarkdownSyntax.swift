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
    
    case list
    
    case horizontalRule
    
    /// To be supported in future versions:
    // case table(columns: [PresentationIntent.TableColumn])
    // case tableCell(columnIndex: Int)
    // case tableHeaderRow
    // case tableRow(rowIndex: Int)
    
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
        case .list: return "List"
        case .horizontalRule: return "Horizontal rule"
        case .codeBlock: return "Code block"
          
        case .quoteBlock: return "Quote"
        case .link: return "Link"
        case .image: return "Image"
      }
      
    }
    
    var leadingCharacters: String? {
      switch self {
        case .heading(let level):
          return String(repeating: "#", count: level)
          
        case .bold:
          return "**"
          
        case .italic:
          return "*"
          
        case .boldItalic:
          return "***"
          
        case .inlineCode:
          return "`"
        case .highlight:
          return "=="
        case .strikethrough:
          return "~~"
        default:
          return nil
          
      }
    }
    
    var trailingCharacters: String? {
      switch self {
        case .heading:
          return "\n"
        case .bold, .italic, .boldItalic, .inlineCode, .highlight, .strikethrough:
          return self.leadingCharacters
          
        default:
          return nil
      }
    }
    
    
    
    
    var shortcut: KeyboardShortcut? {
      switch self {
        case .heading(let level):
          return KeyboardShortcut(key: "\(level)", modifier: .command)
          
        case .bold:
          return KeyboardShortcut(key: "b", modifier: .command)
        case .italic:
          return KeyboardShortcut(key: "i", modifier: .command)
        case .boldItalic:
          return KeyboardShortcut(key: "b", modifier: [.command, .shift])
        case .inlineCode:
          return KeyboardShortcut(key: "`", modifier: nil)
        case .highlight:
          return KeyboardShortcut(key: "h", modifier: .command)
        case .strikethrough:
          return KeyboardShortcut(key: "s", modifier: .command)
          
        default:
          return nil
      }
    }
    
    static func syntax(for shortcut: KeyboardShortcut) -> Self? {
      let result = Self.allCases.first { $0.shortcut == shortcut }
      print("Got a matching shortcut: \(String(describing: result))")
      return result
    }
    
    
  }
  
  
}

extension Markdown.Syntax {
  
  static public var symmetricalSyntax: [Markdown.Syntax] {
    [
      .heading(level: 1),
      .heading(level: 2),
      .heading(level: 3),
      .heading(level: 4),
      .heading(level: 5),
      .heading(level: 6),
      .bold,
      .italic,
      .boldItalic,
      .inlineCode,
      .highlight,
      .strikethrough
    ]
  }
  
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
      .list,
      .horizontalRule,
      .codeBlock,
      .quoteBlock,
      .link,
      .image
    ]
  }
  
  static public var testCases: [Markdown.Syntax] {
    return [
      .bold,
      .italic,
      .boldItalic,
      .strikethrough,
      .highlight,
      .inlineCode,
    ]
  }
}
