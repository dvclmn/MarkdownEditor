//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//


import Foundation
import SwiftUI
import RegexBuilder


class MarkdownBlock: NSTextElement {
  var range: NSTextRange
  let syntax: Markdown.Syntax
  var isComplete: Bool

  init(
    _ textContentManager: NSTextContentManager,
    range: NSTextRange,
    syntax: Markdown.Syntax,
    isComplete: Bool = true
  ) {
    self.range = range
    self.syntax = syntax
    self.isComplete = isComplete
    super.init(textContentManager: textContentManager)
  }
}


extension Markdown.Syntax {
  
  public enum LayoutType {
    case block
    case line
    case inline
  }
  
  public enum Boundary {
    case opening
    case closing
    case single // For syntax that doesn't have separate opening and closing (like horizontal rules)
  }
  
}

public struct Markdown {
  
}

extension Markdown {

  public enum Syntax: Identifiable, Equatable, Hashable, Sendable {
    
    case h1
    case h2
    case h3
    
    case bold
    
    case boldAlt
    
    case italic
    case italicAlt
    
    case boldItalic
    case boldItalicAlt
    
    case strikethrough
    
    case highlight
    
    case inlineCode
    
    case codeBlock
    
    case quoteBlock
    
    case link
    
    case image
    
    nonisolated public var id: String {
      self.name
    }
    
    public var name: String {
      switch self {
          //         case .heading(let level):
          //            "H\(level)"
        case .h1:
          "Heading 1"
        case .h2:
          "Heading 2"
        case .h3:
          "Heading 3"
        case .bold, .boldAlt:
          "Bold"
          
        case .italic, .italicAlt:
          "Italic"
          
        case .boldItalic, .boldItalicAlt:
          "Bold Italic"
          
        case .strikethrough:
          "Strikethrough"
          
        case .highlight:
          "Highlight"
          
        case .inlineCode:
          "Inline code"
          
        case .codeBlock:
          "Code block"
          
        case .quoteBlock:
          "Quote block"
          
        case .link:
          "Link"
          
        case .image:
          "Image"
      }
    }
    
    @MainActor public static let regexPatterns: [Markdown.Syntax: Regex<Substring>] = {
      
      var patterns = [Markdown.Syntax: Regex<Substring>]()
      
      patterns[.inlineCode] = /`[^`\n]+?`/
      patterns[.codeBlock] = /^```\w*[\s\S]*?```$/
      

//      patterns[.inlineCode] = try! Regex("`([^`\n]+?)`")
//      patterns[.codeBlock] = try! Regex("^```(\\w+)?[\\s\\S]*?```$")
      
  //    patterns[.h1] = try! NSRegularExpression(pattern: "^#\\s.*$", options: [.anchorsMatchLines])
  //    patterns[.h2] = try! NSRegularExpression(pattern: "^##\\s.*$", options: [.anchorsMatchLines])
  //    patterns[.h3] = try! NSRegularExpression(pattern: "^###\\s.*$", options: [.anchorsMatchLines])
  //
  //    patterns[.boldItalic] = try! NSRegularExpression(pattern: "\\*\\*\\*(.+?)\\*\\*\\*", options: [])
  //    patterns[.boldItalicAlt] = try! NSRegularExpression(pattern: "___(.+?)___", options: [])
  //
  //    patterns[.bold] = try! NSRegularExpression(pattern: "(?<!\\*)\\*\\*(?!\\*)(.+?)(?<!\\*)\\*\\*(?!\\*)", options: [])
  //    patterns[.boldAlt] = try! NSRegularExpression(pattern: "(?<!_)__(?!_)(.+?)(?<!_)__(?!_)", options: [])
  //
  //    patterns[.italic] = try! NSRegularExpression(pattern: "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", options: [])
  //    patterns[.italicAlt] = try! NSRegularExpression(pattern: "(?<!_)_(?!_)(.+?)(?<!_)_(?!_)", options: [])
  //
  //
  //
  //    patterns[.strikethrough] = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [.anchorsMatchLines])
  //    patterns[.highlight] = try! NSRegularExpression(pattern: "(==)((?!\\1).)+?\\1", options: [.anchorsMatchLines])
  //
  //    patterns[.inlineCode] = try! NSRegularExpression(pattern: "`([^`\n]+?)`", options: [])
  //
  //    patterns[.codeBlock] = try! NSRegularExpression(pattern: "^```(\\w+)?[\\s\\S]*?```$", options: [.anchorsMatchLines])
  //    patterns[.quoteBlock] = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
  //
  //    patterns[.link] = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
  //    patterns[.image] = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
      
      return patterns
    }()
    
    @MainActor public var regex: Regex<Substring> {
      return Markdown.Syntax.regexPatterns[self]!
    }
    
    public static let nsRegexPatterns: [Markdown.Syntax: NSRegularExpression] = {
      
      var patterns = [Markdown.Syntax: NSRegularExpression]()
      
      patterns[.h1] = try! NSRegularExpression(pattern: "^#\\s.*$", options: [.anchorsMatchLines])
      patterns[.h2] = try! NSRegularExpression(pattern: "^##\\s.*$", options: [.anchorsMatchLines])
      patterns[.h3] = try! NSRegularExpression(pattern: "^###\\s.*$", options: [.anchorsMatchLines])
      
      patterns[.boldItalic] = try! NSRegularExpression(pattern: "\\*\\*\\*(.+?)\\*\\*\\*", options: [])
      patterns[.boldItalicAlt] = try! NSRegularExpression(pattern: "___(.+?)___", options: [])
      
      patterns[.bold] = try! NSRegularExpression(pattern: "(?<!\\*)\\*\\*(?!\\*)(.+?)(?<!\\*)\\*\\*(?!\\*)", options: [])
      patterns[.boldAlt] = try! NSRegularExpression(pattern: "(?<!_)__(?!_)(.+?)(?<!_)__(?!_)", options: [])
      
      patterns[.italic] = try! NSRegularExpression(pattern: "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)", options: [])
      patterns[.italicAlt] = try! NSRegularExpression(pattern: "(?<!_)_(?!_)(.+?)(?<!_)_(?!_)", options: [])
      
      
      
      patterns[.strikethrough] = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [.anchorsMatchLines])
      patterns[.highlight] = try! NSRegularExpression(pattern: "(==)((?!\\1).)+?\\1", options: [.anchorsMatchLines])
      
      patterns[.inlineCode] = try! NSRegularExpression(pattern: "`([^`\n]+?)`", options: [])
      
      patterns[.codeBlock] = try! NSRegularExpression(pattern: "^```(\\w+)?[\\s\\S]*?```$", options: [.anchorsMatchLines])
      patterns[.quoteBlock] = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
      
      patterns[.link] = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
      patterns[.image] = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
      
      return patterns
    }()
    
    public var nsRegex: NSRegularExpression {
      return Markdown.Syntax.nsRegexPatterns[self]!
    }
    
    public var isWrappable: Bool {
      switch self {
        case .bold, .boldAlt, .italic, .italicAlt, .inlineCode: true
        default: false
      }
    }
    
    public var layoutType: LayoutType {
      switch self {
        case .h1, .h2, .h3:
            .line
        case .codeBlock, .quoteBlock:
            .block
        default:
            .inline
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
        case .h1:
          "#"
          
        case .h2:
          "##"
          
        case .h3:
          "###"
          
        case .bold:
          "**"
          
        case .boldAlt:
          "__"
          
        case .italic:
          "*"
          
        case .italicAlt:
          "_"
          
        case .boldItalic:
          "***"
          
        case .boldItalicAlt:
          "___"
          
        case .strikethrough:
          "~~"
          
        case .highlight:
          "=="
          
        case .inlineCode:
          "`"
          
        case .codeBlock:
          "```"
          
        case .quoteBlock:
          ">"
          
        case .link:
          ""
          
        case .image:
          ""
      }
    }
    
    public var syntaxCharacterCount: Int? {
      self.syntaxCharacters.count
    }
    
    public var isSyntaxSymmetrical: Bool {
      switch self {
        case .h1, .h2, .h3, .quoteBlock:
          false
        default:
          true
      }
    }
    
    public var shortcut: KeyboardShortcut? {
      switch self {
          
        case .bold, .boldAlt:
            .init("b", modifiers: [.command])
        case .italic, .italicAlt:
            .init("i", modifiers: [.command])
        case .boldItalic, .boldItalicAlt:
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
    
    public var contentAttributes: [NSAttributedString.Key : Any] {
      
      switch self {
          
        case .h1:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: NSColor.systemCyan
          ]
        case .h2:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: NSColor.systemOrange
          ]
        case .h3:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
            .foregroundColor: NSColor.systemGreen
          ]
          
        case .bold, .boldAlt:
          return [
            .font: NSFont.systemFont(ofSize: self.fontSize, weight: .bold),
            .foregroundColor: self.foreGroundColor,
            .backgroundColor: NSColor.clear
          ]
          
        case .italic, .italicAlt:
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
          
        case .boldItalic, .boldItalicAlt:
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
      }
    } // END content attributes
    
    public var syntaxAttributes: [NSAttributedString.Key : Any]  {
      
      switch self {
        case .h1:
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
//
//public extension Markdown.Syntax {
//
//  enum Fragment {
//    case syntax(SyntaxComponent)
//    case content
//
//  }
//
//  enum SyntaxComponent {
//    case open
//    case close
//  }
//
//}
//
//
//public enum SyntaxType {
//  case block
//  case line
//  case inline
//}
//
//
//
//enum CodeLanguage {
//  case swift
//  case python
//}

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


