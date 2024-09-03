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
        case .list: return "List"
        case .horizontalRule: return "Horizontal rule"
        case .codeBlock: return "Code block"
          
        case .quoteBlock: return "Quote"
        case .link: return "Link"
        case .image: return "Image"
      }
      
    }
    
    
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
      
        .list,
      .horizontalRule,
      .codeBlock,
      .quoteBlock,
      .link,
      .image
    ]
  }
  
}
