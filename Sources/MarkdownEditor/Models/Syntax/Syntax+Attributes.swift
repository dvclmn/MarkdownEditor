//
//  MarkdownAttributes.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 20/8/2024.
//

import AppKit
import BaseHelpers
import BaseStyles

extension Markdown.Syntax {

  public func contentAttributes(with config: EditorConfiguration) -> AttributeSet {

    let theme = config.theme
    let defaultFont: NSFont = config.defaultFont

    let set: AttributeSet

    switch self {
      case .heading(let level):

        let font: NSFont
        let foregroundColour: NSColor

        switch level {
          case 1:
            font = config.mediumFont
            foregroundColour = theme.heading1Colour.nsColour

          case 2:
            font = config.mediumFont
            foregroundColour = theme.heading2Colour.nsColour

          case 3:
            font = config.mediumFont
            foregroundColour = theme.heading3Colour.nsColour
            
          default:
            font = config.mediumFont
            foregroundColour = theme.heading4Colour.nsColour
        }

        set = AttributeSet(
          font: font,
          foreground: foregroundColour
        )

      case .bold:
        set = AttributeSet(font: config.boldFont)

      case .italic:
        set = AttributeSet(font: config.italicFont)

      case .boldItalic:
        set = AttributeSet(font: config.boldItalicFont)

      case .strikethrough:
        set = AttributeSet(
          font: config.defaultFont,
          foreground: config.theme.syntaxColour.nsColour,
          additionalAttributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: theme.strikethroughColour.nsColour,

          ]
        )

      case .highlight:
        set = AttributeSet(
          font: defaultFont,
          additionalAttributes: [
            TextBackground.highlight.attributeKey: true
          ]
        )

      case .inlineCode:
        set = AttributeSet(
          font: config.codeFont,
          foreground: theme.codeColour.nsColour,
          additionalAttributes: [
            TextBackground.inlineCode.attributeKey: true
          ]
        )

      case .list:
        set = AttributeSet(
          
        )
        
      case .quoteBlock, .link, .image:
        set = AttributeSet(
          font: config.defaultFont,
          foreground: NSColor.systemCyan
        )

      case .horizontalRule:
        set = AttributeSet(
          font: config.defaultFont,
          foreground: config.theme.syntaxColour.nsColour
        )

      case .codeBlock:
        set = AttributeSet(
          font: config.codeFont,
          foreground: theme.codeColour.nsColour,
          background: .clear,
          additionalAttributes: [
            TextBackground.codeBlock.attributeKey: true
          ]
        )
    }

    return set
  }

  public func syntaxAttributes(with config: EditorConfiguration) -> AttributeSet {

    let theme = config.theme
    let defaultFont: NSFont = config.defaultFont

    let set: AttributeSet

    switch self {
      case .heading(let level):

        let foregroundColour: NSColor

        if level == 1 {
          foregroundColour = theme.heading1Colour.nsColour
        } else if level == 2 {
          foregroundColour = theme.heading2Colour.nsColour
        } else {
          foregroundColour = theme.heading3Colour.nsColour
        }

        set = AttributeSet(
          font: defaultFont,
          foreground: foregroundColour
        )

      case .bold:
        set = AttributeSet(
          font: config.boldFont,
          foreground: config.theme.syntaxColour.nsColour
        )

      case .italic:
        set = AttributeSet(
          font: config.italicFont,
          foreground: config.theme.syntaxColour.nsColour
        )

      case .boldItalic:
        set = AttributeSet(
          font: config.boldItalicFont,
          foreground: config.theme.syntaxColour.nsColour
        )

      case .strikethrough:
        set = AttributeSet(
          font: config.defaultFont,
          foreground: config.theme.syntaxColour.nsColour
        )

      case .highlight:
        set = AttributeSet(
          font: defaultFont,
          foreground: Swatch.greenSpearmint.colour.nsColour,
          additionalAttributes: [
            TextBackground.highlight.attributeKey: true
          ]
        )

      case .inlineCode:
        set = AttributeSet(
          font: config.codeFont,
          foreground: theme.syntaxColour.nsColour,
          additionalAttributes: [
            TextBackground.inlineCode.attributeKey: true
          ]
        )

      case .horizontalRule:
        set = AttributeSet(
          font: config.boldFont,
          background: .cyan
        )

      case .list:
        set = AttributeSet(
          font: config.boldFont,
          foreground: Swatch.greenSpearmint.colour.nsColour,
          background: .clear
        )
        
      case .quoteBlock, .link, .image:
        set = AttributeSet(
          font: config.boldFont,
          background: .cyan
        )

      case .codeBlock:
        set = AttributeSet(
          font: config.codeFont,
          foreground: theme.codeColour.nsColour,
          background: .clear,
          additionalAttributes: [
            TextBackground.codeBlock.attributeKey: true
          ]
        )
    }
    return set
  }
}
