//
//  MarkdownModel.swift
//  Banksia
//
//  Created by Dave Coleman on 20/4/2024.
//

import Foundation
import SwiftUI

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<MarkdownAttributes, T>) -> T {
        return self[T.self]
    }
}


enum FontAttribute: AttributedStringKey {
    typealias Value = Font
    static let name = "Font"
}

enum ForegroundColorAttribute: AttributedStringKey {
    typealias Value = Color
    static let name = "ForegroundColor"
}

enum BackgroundColorAttribute: AttributedStringKey {
    typealias Value = Color
    static let name = "BackgroundColor"
}

enum StrikethroughStyleAttribute: AttributedStringKey {
    typealias Value = NSUnderlineStyle
    static let name = "StrikethroughStyle"
}


struct MarkdownAttributes: AttributeScope {
    let font: FontAttribute
    let foregroundColor: ForegroundColorAttribute
    let backgroundColor: BackgroundColorAttribute
    let strikethroughStyle: StrikethroughStyleAttribute
}




public struct MarkdownDefaults {
    
    public static let fontSize:                 Double = 15
    public static let headerSyntaxSize:        Double = 20
    public static let fontSizeMono:            Double = 14
    public static let syntaxAlpha:             Double = 0.3
    public static let backgroundAlpha:         Double = 0.06
    public static let backgroundAlphaAlt:         Double = 0.5
}

public enum MarkdownSyntax: String, CaseIterable, Identifiable {
    case h1
    case h2
    case h3
    case bold
    case italic
    case boldItalic
    case strikethrough
    case inlineCode
    case codeBlock
    
    public var id: String {
        self.rawValue
    }
    
    public var name: String {
        self.rawValue
    }
    
    public var iconLiterals: String? {
        switch self {
        case .h1:
            "H1"
        case .h2:
            "H2"
        case .h3:
            "H3"
        case .bold:
            "􀅓"
        case .italic:
            "􀅔"
        case .strikethrough:
            "􀅖"
        case .inlineCode:
            "􀙚"
        case .codeBlock:
            "[]"
        default:
            nil
        }
    }
    
    /// https://swiftregex.com
    public var regex: Regex<(Substring, Substring)> {
        switch self {
        case .h1:
            return /# (.*)/
        case .h2:
            return /## (.*)/
        case .h3:
            return /### (.*)/
        case .bold:
            return /\*\*(.*?)\*\*/
        case .italic:
            return /\*(.*?)\*/
        case .boldItalic:
            return /\*\*\*(.*?)\*\*\*/
        case .strikethrough:
            return /\~\~(.*?)\~\~/
        case .inlineCode:
            return /`([^\n`]+)(?!``)`(?!`)/
        case .codeBlock:
            return /(?m)^```([\s\S]*?)^```/
        }
    }
    
    public var hideSyntax: Bool {
        switch self {
        case .h1:
            true
        case .h2:
            false
        case .h3:
            false
        case .bold:
            false
        case .italic:
            false
        case .boldItalic:
            false
        case .strikethrough:
            false
        case .inlineCode:
            false
        case .codeBlock:
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
        case .italic:
            "*"
        case .boldItalic:
            "***"
        case .strikethrough:
            "~~"
        case .inlineCode:
            "`"
        case .codeBlock:
            "```"
        }
    }
    public var syntaxSymmetrical: Bool {
        switch self {
        case .h1, .h2, .h3:
            false
        default:
            true
        }
    }
    
    public var shortcut: KeyboardShortcut {
        switch self {
        case .h1:
                .init("1", modifiers: [.command])
        case .h2:
                .init("2", modifiers: [.command])
        case .h3:
                .init("3", modifiers: [.command])
        case .bold:
                .init("b", modifiers: [.command])
        case .italic:
                .init("i", modifiers: [.command])
        case .boldItalic:
                .init("b", modifiers: [.command, .shift])
        case .strikethrough:
                .init("u", modifiers: [.command])
        case .inlineCode:
                .init("`", modifiers: [])
        case .codeBlock:
                .init("k", modifiers: [.command, .shift])
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
        case .inlineCode, .codeBlock:
            NSColor(.purple)
        default:
                .textColor.withAlphaComponent(0.85)
        }
    }
    
    
    public var contentAttributes: [NSAttributedString.Key : Any] {
        
        switch self {
        case .h1:
            return [
                .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                .foregroundColor: self.foreGroundColor
            ]
            
        case .h2:
            
            return [
                .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                .foregroundColor: self.foreGroundColor
            ]
            
        case .h3:
            return [
                .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                .foregroundColor: self.foreGroundColor
            ]
            
        case .bold:
            return [
                .font: NSFont.systemFont(ofSize: self.fontSize, weight: .bold),
                .foregroundColor: self.foreGroundColor
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
                .foregroundColor: self.foreGroundColor
            ]
            
        case .boldItalic:
            let bodyDescriptor = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
            let font = NSFont(descriptor: bodyDescriptor.withSymbolicTraits([.italic, .bold]), size: self.fontSize)
            return [
                .font: font as Any,
                .foregroundColor: self.foreGroundColor
            ]
            
        case .strikethrough:
            return [
                .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
                .foregroundColor: self.foreGroundColor,
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]
            
        case .inlineCode, .codeBlock:
            return [
                .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .medium),
                .foregroundColor: self.foreGroundColor
//                .backgroundColor: NSColor.white.withAlphaComponent(MarkdownDefaults.backgroundAlpha)
            ]
        }
    } // END content attributes
    
    public var syntaxAttributes: [NSAttributedString.Key : Any]  {
        switch self {
        case .h1:
            
            return [
                .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .light),
                .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha)
            ]
        case .h2:
            return [
                .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .light),
                .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha)
            ]
        case .h3:
            return [
                .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .light),
                .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha)
            ]
        case .bold, .italic, .boldItalic, .strikethrough:
            return [
                .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .regular),
                .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha)
            ]
        case.inlineCode, .codeBlock:
            return [
                .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .regular),
                .foregroundColor: NSColor.textColor.withAlphaComponent(MarkdownDefaults.syntaxAlpha)
            ]
            
        }
    }
}

enum CodeLanguage {
    case swift
    case python
}
