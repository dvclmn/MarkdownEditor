//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//


import Foundation
import SwiftUI
import RegexBuilder

// TODO: Shortcut to move lines up aND DOWN

public protocol MarkdownSyntax: Equatable, Sendable {
  
  associatedtype RegexOutput
  associatedtype Structure
  
  var name: String { get }
  var regex: Regex<RegexOutput> { get }
  var structure: Structure { get }
  var contentAttributes: AttributeSet { get }
  var syntaxAttributes: AttributeSet { get }
}

public protocol MarkdownIntent: Equatable, Sendable {
  associatedtype StructureType
  var syntax: Markdown.Syntax { get }
  var type: StructureType { get }
}





public typealias AnyMarkdownSyntax = (any MarkdownSyntax)

public typealias AnyMarkdownIntent = (any MarkdownIntent)

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
  
  
  
  //  struct SingleCaptureSyntax: MarkdownSyntax {
  //    public typealias RegexOutput = (Substring, Substring)
  //
  //    public let name: String
  //    nonisolated(unsafe) public let regex: Regex<RegexOutput>
  //
  //
  //    public var contentAttributes: AttributeSet = .highlighter
  //    public var syntaxAttributes: AttributeSet = .codeBlock
  //
  //    public static func == (lhs: SingleCaptureSyntax, rhs: SingleCaptureSyntax) -> Bool {
  //      return lhs.name == rhs.name
  //    }
  //
  //  }
  //
  //  struct DoubleCaptureSyntax: MarkdownSyntax {
  //
  //    public typealias RegexOutput = (Substring, Substring, Substring)
  //
  //    public let name: String
  //    nonisolated(unsafe) public let regex: Regex<RegexOutput>
  //
  //    public var contentAttributes: AttributeSet = .highlighter
  //    public var syntaxAttributes: AttributeSet = .codeBlock
  //
  //    public static func == (lhs: DoubleCaptureSyntax, rhs: DoubleCaptureSyntax) -> Bool {
  //      return lhs.name == rhs.name
  //    }
  //  }
  
  
  
  
  
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
//  struct MarkdownElement {
//    let type: InlinePresentationIntent
//    let range: NSRange
//    let additionalInfo: [String: Any]?
//    
//    struct ElementType {
//      let name: String
//      let structure: (Inline)PresentationIntent
//      let regex: Regex<AnyRegexOutput>
//    }
//    
//  }
  
  
  
  
  
  @MainActor
  struct SyntaxStruct: Equatable {
    
    static let all: [AnyMarkdownSyntax] = [
      h1,
      h2,
      h3,
      bold,
      boldAlt,
      italic,
      italicAlt,
      boldItalic,
      boldItalicAlt,
      strikethrough,
      highlight,
      inlineCode,
      codeBlock,
      quoteBlock,
      link,
      image
      
    ]
    
    static let h1 = SingleCaptureSyntax(
      name: "H1",
      regex: /# (.*)/,
      structure: .line
    )
    static let h2 = SingleCaptureSyntax(
      name: "H2",
      regex: /## (.*)/,
      structure: .line
    )
    static let h3 = SingleCaptureSyntax(
      name: "H3",
      regex: /### (.*)/,
      structure: .line
    )
    static let bold = SingleCaptureSyntax(
      name: "Bold",
      regex: /\\*\\*(.*?)\\*\\*/
    )
    static let boldAlt = SingleCaptureSyntax(
      name: "Bold Alt",
      regex: /__(.*?)__/
    )
    static let italic = SingleCaptureSyntax(
      name: "Italic",
      regex: /\\*(.*?)\\*/
    )
    static let italicAlt = SingleCaptureSyntax(
      name: "Italic Alt",
      regex: /_(.*?)_/
    )
    static let boldItalic = SingleCaptureSyntax(
      name: "Bold Italic",
      regex: /\\*\\*\\*(.*?)\\*\\*\\*/
    )
    static let boldItalicAlt = SingleCaptureSyntax(
      name: "Bold Italic Alt",
      regex: /___(.*?)___/
    )
    static let strikethrough = SingleCaptureSyntax(
      name: "Strikethrough",
      regex: /~~(.*?)~~/
    )
    static let highlight = SingleCaptureSyntax(
      name: "Highlight",
      regex: /==(.*?)==/
    )
    static let inlineCode = SingleCaptureSyntax(
      name: "Inline Code",
      regex: /`([^\\n`]+)(?!``)`(?!`)/
    )
    static let codeBlock = SingleCaptureSyntax(
      name: "Code Block",
      regex: /(?m)^```([\\s\\S]*?)^```/,
      structure: .block
    )
    
    static let quoteBlock = SingleCaptureSyntax(
      name: "Quote Block",
      regex: /^> (.*)/,
      structure:
    )
    
    static let link = DoubleCaptureSyntax(
      name: "Link",
      regex: /\[([^\]]+)\]\(([^\)]+)\)/
    )
    static let image = DoubleCaptureSyntax(
      name: "Image",
      regex: /!\[([^\]]+)\]\(([^\)]+)\)/)
    
  }
}



extension Markdown {
  
  
  public enum EmphasisStyle: Sendable {
    case asterisk
    case underscore
  }
  
  public enum ListStyle: Sendable {
    case ordered
    case unordered
  }
  
  public enum Syntax: Identifiable, Equatable, Hashable, Sendable {
    
    case heading(level: Int)
    
    case bold(style: EmphasisStyle)
    case italic(style: EmphasisStyle)
    case boldItalic(style: EmphasisStyle)
    
    case strikethrough
    case highlight
    case inlineCode
    
    case list(style: ListStyle)
    
    
    case horiztonalRule
    
//    case table(columns: [PresentationIntent.TableColumn])
    // case tableCell(columnIndex: Int)
    // case tableHeaderRow
    // case tableRow(rowIndex: Int
    
    case codeBlock(language: LanguageHint?)
    case quoteBlock
    
    case link
    case image
    
    nonisolated public var id: String {
      self.name
    }
    
    public var intentIdentity: Int {
      switch self {
        case .heading(let level):
          return 1 + level
        case .bold(let style):
          switch style {
            case .asterisk:
              return 2
            case .underscore:
              return 3
          }
        case .italic(let style):
          switch style {
            case .asterisk:
              return 4
            case .underscore:
              return 5
          }
        case .boldItalic(let style):
          switch style {
            case .asterisk:
              return 6
            case .underscore:
              return 7
          }
        case .strikethrough:
          return 8
        case .highlight:
          return 9
        case .inlineCode:
          return 10
        case .list(let style):
          switch style {
            case .ordered:
              return 11
            case .unordered:
              return 12
          }
        case .horiztonalRule:
          return 13
        case .codeBlock(let language):
          guard let language = language else { return 14 }
          return 14 + (language.intentIdentifier * 100)
        case .quoteBlock:
          return 15
        case .link:
          return 16
        case .image:
          return 17
      }
    }
    
    public var name: String {
      switch self {
        default: "Default"
          //         case .heading(let level):
          //            "H\(level)"
//        case .h1:
//          "Heading 1"
//        case .h2:
//          "Heading 2"
//        case .h3:
//          "Heading 3"
//        case .bold, .boldAlt:
//          "Bold"
//          
//        case .italic, .italicAlt:
//          "Italic"
//          
//        case .boldItalic, .boldItalicAlt:
//          "Bold Italic"
//          
//        case .strikethrough:
//          "Strikethrough"
//          
//        case .highlight:
//          "Highlight"
//          
//        case .inlineCode:
//          "Inline code"
//          
//        case .codeBlock:
//          "Code block"
//          
//        case .quoteBlock:
//          "Quote block"
//          
//        case .link:
//          "Link"
//          
//        case .image:
//          "Image"
      }
    }
    
    
    
    public var isWrappable: Bool {
      switch self {
        case .bold, .italic, .inlineCode: true
        default: false
      }
    }
    
//    public func structure<S: MarkdownStructure>(for syntax: Self) -> S {
//      switch self {
//        case .heading(let level):
//          BlockStructure(name: <#T##String#>, type: <#T##PresentationIntent#>)
//        case .bold(let style):
//          <#code#>
//        case .italic(let style):
//          <#code#>
//        case .boldItalic(let style):
//          <#code#>
//        case .strikethrough:
//          <#code#>
//        case .highlight:
//          <#code#>
//        case .inlineCode:
//          <#code#>
//        case .list(let style):
//          <#code#>
//        case .horiztonalRule:
//          <#code#>
//        case .codeBlock(let language):
//          <#code#>
//        case .quoteBlock:
//          <#code#>
//        case .link:
//          <#code#>
//        case .image:
//          <#code#>
//      }
//    }
    

    public var intent: AnyMarkdownIntent {
      switch self {
        case .heading(let level):
          BlockIntent(syntax: .heading(level: level), type: PresentationIntent(.header(level: level), identity: level))
        case .bold(let style):
          InlineIntent(syntax: .bold(style: style), type: .emphasized)
        case .italic(let style):
          InlineIntent(syntax: .italic(style: style), type: .emphasized)
        case .boldItalic(let style):
          InlineIntent(syntax: .boldItalic(style: style), type: .stronglyEmphasized)
        case .strikethrough:
          InlineIntent(syntax: .strikethrough, type: .strikethrough)
        case .highlight:
          InlineIntent(syntax: .highlight, type: .highlight)
        case .inlineCode:
          InlineIntent(syntax: .inlineCode, type: .code)
        case .list(let style):
          BlockIntent(syntax: .list(style: style), type: .list(style: style))
        case .horiztonalRule:
          BlockIntent(syntax: .horiztonalRule, type: PresentationIntent(.thematicBreak, identity: self.intentIdentity))
        case .codeBlock(let language):
          BlockIntent(syntax: self, type: PresentationIntent(.codeBlock(languageHint: language?.string), identity: self.intentIdentity))
        case .quoteBlock:
          BlockIntent(syntax: self, type: PresentationIntent(.blockQuote, identity: self.intentIdentity))
        case .link:
          InlineIntent(syntax: self, type: .link)
        case .image:
          InlineIntent(syntax: self, type: .image)
      }
        
      
    }
    
    public var hideSyntax: Bool {
      switch self {
        case .bold:
          true
        default:
          false
      }
    }
    
    public var syntaxCharacters: String {
      switch self {
        case .heading(let level):
          
          let maxLevel = 6
          
          /// Could also be written like this:
          /// ```
          /// var result = ""
          /// for _ in 1...min(level, 6) {
          ///   result += "#"
          /// }
          /// return result
          ///
          /// ```
          let levelWithLimit = min(level, maxLevel)
          return String(repeating: "#", count: levelWithLimit)
        case .bold(let style):
          switch style {
            case .asterisk: return "**"
            case .underscore: return "__"
          }
        case .italic(let style):
          switch style {
            case .asterisk: return "*"
            case .underscore: return "_"
          }
        case .boldItalic(let style):
          switch style {
            case .asterisk: return "***"
            case .underscore: return "___"
          }
        case .strikethrough: return "~~"
        case .highlight: return "=="
        case .inlineCode: return "`"
          
          // TODO: Can improve implementation here
        case .list: return "- "
        case .horiztonalRule: return "---"
        case .codeBlock(let language): return "```\(language?.string ?? "")"
        case .quoteBlock: return "> "
        case .link: return "?"
        case .image: return "?"
      }
    }
    
    public var syntaxCharacterCount: Int? {
      self.syntaxCharacters.count
    }
    
    public var isSyntaxSymmetrical: Bool {
      switch self {
        case .heading, .quoteBlock:
          false
        default:
          true
      }
    }
    
//    public var shortcut: KeyboardShortcut? {
//      switch self {
//          
//        case .bold, .boldAlt:
//            .init("b", modifiers: [.command])
//        case .italic, .italicAlt:
//            .init("i", modifiers: [.command])
//        case .boldItalic, .boldItalicAlt:
//            .init("b", modifiers: [.command, .shift])
//        case .strikethrough:
//            .init("u", modifiers: [.command])
//        case .inlineCode:
//            .init("c", modifiers: [.command, .option])
//        case .codeBlock:
//            .init("k", modifiers: [.command, .shift])
//        default:
//          nil
//      }
//    }
    
    public var fontSize: Double {
      switch self {
        case .inlineCode, .codeBlock:
          14
        default: MarkdownDefaults.fontSize
      }
    }
    public var foreGroundColor: NSColor {
      switch self {
        default:
            .textColor.withAlphaComponent(0.85)
      }
    }
    
    public var contentAttributes: Attributes {
      
      switch self {
          
        case .heading(let level):
          
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: NSColor.systemCyan
          ]
          
        case .bold:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .bold),
            .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.clear
          ]
          
        case .italic:
          let bodyDescriptor = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
          let italicDescriptor = bodyDescriptor.withSymbolicTraits(.italic)
          let mediumWeightDescriptor = italicDescriptor.addingAttributes([
            .traits: [
              NSFontDescriptor.TraitKey.weight: NSFont.Weight.medium
            ]
          ])
          let font = NSFont(descriptor: mediumWeightDescriptor, size: self.fontSize)
          return [
            .font: font as Any,
            .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.clear
          ]
          
        case .boldItalic:
          let bodyDescriptor = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
          let font = NSFont(descriptor: bodyDescriptor.withSymbolicTraits([.italic, .bold]), size: self.fontSize)
          return [
            .font: font as Any,
            .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.clear
          ]
          
        case .strikethrough:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.yellow
          ]
          
        case .highlight:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: self.foreGroundColor,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .backgroundColor: NSColor.clear
          ]
          
        case .inlineCode:
          return [
            .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundInlineCode)
          ]
        case .codeBlock:
          return [
            .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: self.foreGroundColor,
            //          .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)
          ]
          
        case .quoteBlock:
          return [
            //               .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .medium),
            //               .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)
          ]
          
        case .link:
          return [:]
        case .image:
          return [:]
        case .list(style: let style):
          return [:]
        case .horiztonalRule:
          return [:]
      }
    } // END content attributes
    
    public var syntaxAttributes: [NSAttributedString.Key : Any]  {
      
      switch self {
        case .heading(let level):
          return [
            .foregroundColor: NSColor.systemMint
          ]
        case .inlineCode:
          return [
            .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .regular),
            .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha),
            .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundInlineCode)
          ]
        case .codeBlock:
          return [
            .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .regular),
            .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha),
            .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)
          ]
        default:
          return [
            .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .regular),
            .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha)
          ]
      }
    }
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


