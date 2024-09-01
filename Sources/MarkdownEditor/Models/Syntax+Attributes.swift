//
//  MarkdownAttributes.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit
import Foundation
import BaseHelpers
import TextCore
import BaseStyles

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
  
  public static let lineHeightMultiplier:     Double = 1.3
//  public static let lineSpacing:              Double = 6
  public static let paragraphSpacing:         Double = 0
  
  public static let paddingX: Double = 30
  public static let paddingY: Double = 30
}



public extension AttributeSet {
  
  static let markdownDefaults: AttributeSet = [
    .foregroundColor: NSColor.white,
    .backgroundColor: NSColor.clear,
    .font: MarkdownDefaults.defaultFont
  ]
}




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
      case .inlineCode:
        NSColor(Swatch.peachVibrant.colour)
      default:
          .textColor.withAlphaComponent(0.85)
    }
  }

  var contentFontAttributes: Attributes? {
    
    switch self {
        
      case .heading:
        return [
          .font: NSFont.systemFont(ofSize: self.fontSize, weight: .medium),
        ]
        
      case .bold:
        return [
          .font: NSFont.systemFont(ofSize: self.fontSize, weight: .bold),
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
        ]
        
      case .boldItalic:
        
        return [
          .font: NSFont.systemFont(ofSize: self.fontSize, weight: .bold),
        ]
        
      case .inlineCode, .codeBlock:
        return [
          .font: NSFont.monospacedSystemFont(ofSize: self.fontSize, weight: .medium)
        ]
      
      case .link, .image, .list, .strikethrough, .horizontalRule, .highlight, .quoteBlock:
        return nil
    }
  }
  var contentRenderingAttributes: Attributes {
        
        switch self {
            
          case .heading:
            return [
              .foregroundColor: NSColor.systemCyan
            ]
            
          case .bold:
            return [

              .foregroundColor: NSColor.systemPink,
//              .foregroundColor: self.foreGroundColor,
              .backgroundColor: NSColor.clear
            ]
            
          case .italic:
            
            return [
              .foregroundColor: NSColor.systemTeal,
//              .foregroundColor: self.foreGroundColor,
              .backgroundColor: NSColor.clear
            ]
            
          case .boldItalic:
            
            return [
              .foregroundColor: NSColor.systemMint,
//              .foregroundColor: self.foreGroundColor,
              .backgroundColor: NSColor.clear
            ]
            
          case .strikethrough:
            return [
              .foregroundColor: NSColor.green,
            ]
            
          case .highlight:
            return [
              .foregroundColor: NSColor.black,
              .backgroundColor: NSColor.yellow.withAlphaComponent(0.7)
            ]
            
          case .inlineCode:
            return [
              .foregroundColor: NSColor.blue
            ]
          case .codeBlock:
            return [
              .foregroundColor: NSColor.systemBrown,
            ]
            
          case .quoteBlock:
            return [
              .foregroundColor: NSColor.systemIndigo,
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
