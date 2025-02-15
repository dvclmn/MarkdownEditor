//
//  Theme.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/9/2024.
//

import SwiftUI
import BaseStyles
import MemberwiseInit
import BaseHelpers

@MemberwiseInit(.public)
public struct MarkdownTheme: Sendable, Equatable {

  public var fontSize: CGFloat = 14
  public var textColour: Color = .primary.opacity(0.95)
  public var syntaxColour: Color = .secondary.opacity(0.7)

  public var insertionPointColour: Color = .purple
  public var lineHeight: CGFloat = 1.8
  public var insets: CGFloat = 20
  public var overScrollAmount: CGFloat = .zero

  /// Code
  public var codeColour: Color = Swatch.blueChalk.colour
  public var inlineCodeBackgroundColour: Color = Swatch.plum15.colour
  public var codeBlockBackgroundColour: Color = Swatch.plum10.colour
  public var codeBackgroundRounding: CGFloat = 4
  
  /// Highlight
  public var highlightBackground: Color = Swatch.greenForest.colour
  
  /// Headings
  public var heading1Colour: Color = Swatch.greenSpearmint.colour
  public var heading2Colour: Color = Swatch.purpleEggplant.colour
  public var heading3Colour: Color = Swatch.peachLight.colour
  public var heading4Colour: Color = Swatch.blueChalk.colour

  public var strikethroughColour: Color = .red
  
  public var maxReadingWidth: CGFloat? = 680
}

extension MarkdownTheme {
  public static var `default`: MarkdownTheme {
    .init()
  }
}

extension EditorConfiguration {

  public var codeFontSize: CGFloat {
    max(10, theme.fontSize - 0)
  }

  public var defaultFont: NSFont {
    NSFont.systemFont(ofSize: theme.fontSize)
  }

  public var italicFont: NSFont {
    let systemFont = NSFont.systemFont(ofSize: theme.fontSize)
    let fontDescriptor = systemFont.fontDescriptor.withSymbolicTraits(.italic)
    return NSFont(descriptor: fontDescriptor, size: theme.fontSize) ?? systemFont
  }

  public var boldItalicFont: NSFont {
    let systemFont = NSFont.systemFont(ofSize: theme.fontSize)
    let fontDescriptor = systemFont.fontDescriptor.withSymbolicTraits([.bold, .italic])
    return NSFont(descriptor: fontDescriptor, size: theme.fontSize) ?? systemFont
  }

  public var boldFont: NSFont {
    NSFont.boldSystemFont(ofSize: theme.fontSize)
  }
  
  public var mediumFont: NSFont {
    NSFont.systemFont(ofSize: theme.fontSize, weight: .medium)
  }

  public var codeFont: NSFont {
    NSFont.monospacedSystemFont(ofSize: codeFontSize, weight: .medium)
  }
}
