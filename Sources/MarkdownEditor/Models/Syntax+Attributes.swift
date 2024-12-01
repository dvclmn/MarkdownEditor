//
//  MarkdownAttributes.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit
import Foundation
import BaseHelpers



public extension Markdown.Syntax {
  

  func contentAttributes(with config: MarkdownEditorConfiguration) -> AttributeSet {
    
    let theme = config.theme
    
    let font: NSFont
    let foregroundColour: NSColor
    let backgroundColour: NSColor
    
    switch self {
      case .heading(let level):
        if level == 1 {
          foregroundColour = theme.heading1Colour.nsColour
        } else if level == 2 {
          foregroundColour = theme.heading2Colour.nsColour
        } else  {
          foregroundColour = theme.heading3Colour.nsColour
        }
        font = theme.defaultFont
        backgroundColour = .clear
        
      case .bold:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .italic:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .boldItalic:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .strikethrough:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .highlight:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .inlineCode:
        font = theme.codeFont
        foregroundColour = theme.codeColour.nsColour
        backgroundColour = theme.codeBackgroundColour.nsColour
        
      case .list:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .horizontalRule:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .codeBlock:
        font = theme.codeFont
        foregroundColour = theme.codeColour.nsColour
        backgroundColour = .clear
//        backgroundColour = theme.codeBackgroundColour.nsColour
        
      case .quoteBlock:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .link:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .image:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
    }
    
    let result: AttributeSet = [
      .font: font,
      .foregroundColor: foregroundColour,
      .backgroundColor: backgroundColour
    ]
    
    return result
  }
  
  func syntaxAttributes(with config: MarkdownEditorConfiguration) -> AttributeSet {
    
    let theme = config.theme
    
    let font: NSFont
    let foregroundColour: NSColor
    let backgroundColour: NSColor
    
    switch self {
      case .heading(let level):
        if level == 1 {
          foregroundColour = NSColor(theme.heading1Colour)
        } else if level == 2 {
          foregroundColour = NSColor(theme.heading2Colour)
        } else  {
          foregroundColour = NSColor(theme.heading3Colour)
        }
        font = theme.defaultFont
        backgroundColour = .clear
        
      case .bold:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .italic:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .boldItalic:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .strikethrough:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .highlight:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .inlineCode:
        font = theme.codeFont
        foregroundColour = .systemBrown
        backgroundColour = theme.codeBackgroundColour.nsColour
        
      case .list:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .horizontalRule:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .codeBlock:
        font = theme.codeFont
        foregroundColour = .systemBrown
        backgroundColour = .clear
        
      case .quoteBlock:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .link:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
      case .image:
        font = theme.defaultFont
        foregroundColour = .labelColor
        backgroundColour = .clear
        
    }
    
    let result: AttributeSet = [
      .font: font,
      .foregroundColor: foregroundColour,
      .backgroundColor: backgroundColour
    ]
    
    return result
  }

//  var contentRenderingAttributes: Attributes {
//        
//        switch self {
//            
//          case .heading:
//            return [
//              .foregroundColor: NSColor.systemCyan
//            ]
//            
//          case .bold:
//            return [
//
//              .foregroundColor: NSColor.systemPink,
//              .backgroundColor: NSColor.clear
//            ]
//            
//          case .italic:
//            
//            return [
//              .foregroundColor: NSColor.systemTeal,
//              .backgroundColor: NSColor.clear
//            ]
//            
//          case .boldItalic:
//            
//            return [
//              .foregroundColor: NSColor.systemMint,
//              .backgroundColor: NSColor.clear
//            ]
//            
//          case .strikethrough:
//            return [
//              .foregroundColor: NSColor.green,
//            ]
//            
//          case .highlight:
//            return [
//              .foregroundColor: NSColor.black,
//              .backgroundColor: NSColor.yellow.withAlphaComponent(0.7)
//            ]
//            
//          case .inlineCode:
//            return [
//              .foregroundColor: NSColor.systemGreen,
//              .backgroundColor: Markdown.Syntax.inlineCodeBackground
//              
//            ]
//          case .codeBlock:
//            return [
//              .foregroundColor: NSColor.systemBrown,
//            ]
//            
//          case .quoteBlock:
//            return [
//              .foregroundColor: NSColor.systemIndigo,
//            ]
//            
//          case .link:
//            return [:]
//          case .image:
//            return [:]
//          case .list:
//            return [:]
//          case .horizontalRule:
//            return [:]
//        }
//      } // END content attributes
//      
//  var syntaxRenderingAttributes: [NSAttributedString.Key : Any]  {
//    
//    switch self {
//      case .heading:
//        return [
//          .foregroundColor: NSColor.systemMint
//        ]
//      case .inlineCode:
//        return [
//          .font:
//          .foregroundColor: NSColor.gray,
//          .backgroundColor: Markdown.Syntax.inlineCodeBackground
//          
//        ]
//      case .codeBlock:
//        return [
//          .foregroundColor: Markdown.Syntax.syntaxColour,
//          .backgroundColor: Markdown.Syntax.codeBackground
//        ]
//      default:
//        return [
//          .foregroundColor: Markdown.Syntax.syntaxColour
//        ]
//    }
//  }
}
