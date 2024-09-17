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


public extension Markdown.Syntax {
  
  static let syntaxColour: NSColor = NSColor.gray
  static let codeBackground: NSColor = NSColor.black.withAlphaComponent(0.4)

  var contentRenderingAttributes: Attributes {
        
        switch self {
            
          case .heading:
            return [
              .foregroundColor: NSColor.systemCyan
            ]
            
          case .bold:
            return [

              .foregroundColor: NSColor.systemPink,
              .backgroundColor: NSColor.clear
            ]
            
          case .italic:
            
            return [
              .foregroundColor: NSColor.systemTeal,
              .backgroundColor: NSColor.clear
            ]
            
          case .boldItalic:
            
            return [
              .foregroundColor: NSColor.systemMint,
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
              .foregroundColor: NSColor.systemGreen
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
      
  var syntaxRenderingAttributes: [NSAttributedString.Key : Any]  {
    
    switch self {
      case .heading:
        return [
          .foregroundColor: NSColor.systemMint
        ]
      case .inlineCode:
        return [
          .foregroundColor: Markdown.Syntax.syntaxColour,
          .backgroundColor: Markdown.Syntax.codeBackground
        ]
      case .codeBlock:
        return [
          .foregroundColor: Markdown.Syntax.syntaxColour,
          .backgroundColor: Markdown.Syntax.codeBackground
        ]
      default:
        return [
          .foregroundColor: Markdown.Syntax.syntaxColour
        ]
    }
  }
}
