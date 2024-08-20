//
//  MarkdownAttributes.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit
import Foundation

public extension Markdown.Syntax {
  
  var fontSize: Double {
    switch self {
      case .inlineCode, .codeBlock:
        14
      default: MarkdownDefaults.fontSize
    }
  }
  var foreGroundColor: NSColor {
    switch self {
      default:
          .textColor.withAlphaComponent(0.85)
    }
  }

  var contentAttributes: Attributes {
        
    
        switch self {
            
          case .heading:
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
            
            return [
              .foregroundColor: self.foreGroundColor,
              .backgroundColor: NSColor.clear
            ]
            
          case .strikethrough:
            return [
              .strikethroughStyle: NSUnderlineStyle.thick.rawValue,
              .strikethroughColor: NSColor.red,
              .foregroundColor: NSColor.green,
              .baselineOffset: 0
              //            .foregroundColor: self.foreGroundColor,
            ]
            
          case .highlight:
            return [
              .foregroundColor: self.foreGroundColor,
              .backgroundColor: NSColor.yellow.withAlphaComponent(0.3)
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
          case .list:
            return [:]
          case .horizontalRule:
            return [:]
        }
      } // END content attributes
      
  var syntaxAttributes: [NSAttributedString.Key : Any]  {
    
    switch self {
      case .heading:
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
