//
//  MarkdownModel.swift
//  Banksia
//
//  Created by Dave Coleman on 20/4/2024.
//

#if os(macOS)


import Foundation
import SwiftUI
import RegexBuilder



public struct LineToken {
    
    /// Token range, relative to the start of the document.
    ///
    let range: NSRange
    
    /// Token start position, relative to the line on which the token is located.
    ///
    let column: Int
    
    /// The kind of token.
    ///
    let type: MarkdownSyntax

}



public enum LayoutType {
    case any
    case line
    case block
}

public enum MarkdownSyntax: String, CaseIterable, Identifiable, Equatable {
    case body
    case h1
    case h2
    case h3
    case bold
    case boldAlt
    case italic
    case italicAlt
    case boldItalic
    case strikethrough
    case inlineCode
    case codeBlock
    case quoteBlock
    
    nonisolated public var id: String {
        self.rawValue
    }
    
    public var name: String {
        switch self {
            case .body:
                "Body"
            case .h1:
                "H1"
            case .h2:
                "H2"
            case .h3:
                "H3"
            case .bold:
                "Bold"
            case .boldAlt:
                "Bold"
            case .italic:
                "Italic"
            case .italicAlt:
                "Italic"
            case .boldItalic:
                "Bold Italic"
            case .strikethrough:
                "Strikethrough"
            case .inlineCode:
                "Inline code"
            case .codeBlock:
                "Code block"
            case .quoteBlock:
                "Quote block"
        }
    }
    
    var regex: Regex<Substring> {
        switch self {
            case .bold:
                Regex {
                    "**"
                    ZeroOrMore(.reluctant) {
                        /./
                    }
                    "**"
                }
                .anchorsMatchLineEndings()
                .ignoresCase()
                
            case .italic:
                Regex {
                    "*"
                    ZeroOrMore(.reluctant) {
                        /./
                    }
                    "*"
                }
                .anchorsMatchLineEndings()
                .ignoresCase()
            case .inlineCode:
                Regex {
                    "`"
                    ZeroOrMore(.reluctant) {
                        /./
                    }
                    "`"
                }
                .anchorsMatchLineEndings()
                .ignoresCase()
            case .codeBlock:
                Regex {
                    /^/
                    "```"
                    ZeroOrMore(.reluctant) {
                        CharacterClass(
                            .whitespace,
                            .whitespace.inverted
                        )
                    }
                    "```"
                    /$/
                }
                .anchorsMatchLineEndings()
                .ignoresCase()
                
            default:
                Regex {
                    "`"
                    ZeroOrMore(.reluctant) {
                        /./
                    }
                    "`"
                }
                .anchorsMatchLineEndings()
                .ignoresCase()
        }
        
    }
    
    public var layoutType: LayoutType {
        switch self {
            case .h1, .h2, .h3:
                    .line
            case .codeBlock, .quoteBlock:
                    .block
            default:
                    .any
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
    
    public var syntaxCharacters: String? {
        switch self {
            case .body:
                nil
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
            case .strikethrough:
                "~~"
            case .inlineCode:
                "`"
            case .codeBlock:
                "```"
            case .quoteBlock:
                ">"
        }
    }
    
    public var syntaxCharacterCount: Int? {
        self.syntaxCharacters?.count
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
            case .h1:
                    .init("1", modifiers: [.command])
            case .h2:
                    .init("2", modifiers: [.command])
            case .h3:
                    .init("3", modifiers: [.command])
            case .bold, .boldAlt:
                    .init("b", modifiers: [.command])
            case .italic, .italicAlt:
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
    
    public var fontSize: Double {
        switch self {
            case .h1:
                28
            case .h2:
                24
            case .h3:
                18
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
                
            case .body:
                return [
                    .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                    .foregroundColor: self.foreGroundColor,
                    .backgroundColor: NSColor.clear
                ]
            case .h1:
                return [
                    .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                    .foregroundColor: self.foreGroundColor,
                    .backgroundColor: NSColor.clear
                    
                ]
                
            case .h2:
                
                return [
                    .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                    .foregroundColor: self.foreGroundColor,
                    .backgroundColor: NSColor.clear
                ]
                
            case .h3:
                return [
                    .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                    .foregroundColor: self.foreGroundColor,
                    .backgroundColor: NSColor.clear
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
                    .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)
                ]
                
            case .quoteBlock:
                return [
                    .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .medium),
                    .foregroundColor: self.foreGroundColor,
                    .backgroundColor: NSColor.black.withAlphaComponent(MarkdownDefaults.backgroundCodeBlock)
                ]
        }
    } // END content attributes
    
    public var syntaxAttributes: [NSAttributedString.Key : Any]  {
        
        switch self {
                
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
                    .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha),
                    .backgroundColor: NSColor.clear
                ]
        }
    }
}

enum CodeLanguage {
    case swift
    case python
}

enum SyntaxComponent {
    case open
    case content
    case close
}





public struct MarkdownEditorConfiguration {
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





public struct MarkdownDefaults {
    
    public static let defaultFont =               NSFont.systemFont(ofSize: MarkdownDefaults.fontSize, weight: MarkdownDefaults.fontWeight)
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



#endif
