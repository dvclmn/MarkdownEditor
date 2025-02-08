//
//  Editor+Config.swift
//  Components
//
//  Created by Dave Coleman on 7/2/2025.
//

import SwiftUI
import MemberwiseInit
import BaseHelpers

@MemberwiseInit(.public)
public struct EditorConfig {
  public var isEditable: Bool = true
  public var insets: CGFloat = 20
  public var theme: MarkdownTheme = .init()
}

extension EditorConfig {

  var codeBlockPadding: CGFloat {
    self.insets * 0.4
  }

  var defaultTypingAttributes: Attributes {

    let font = NSFont.systemFont(ofSize: theme.fontSize)
    
    let paragraphStyle = defaultParagraphStyle

    let attributes: Attributes = [
      .font: font,
      .foregroundColor: theme.textColour,
      .paragraphStyle: paragraphStyle,
    ]

    return attributes
  }

  var defaultParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = theme.lineHeight

    return paragraphStyle
  }

}

@MemberwiseInit(.public)
public struct MarkdownTheme: Sendable, Equatable {
  public var fontSize: CGFloat = 14
  public var textColour: NSColor = NSColor.textColor.withAlphaComponent(0.85)
  public var lineHeight: CGFloat = 0.0
  
  public var codeColour: NSColor = NSColor.systemOrange

  var codeFontSize: CGFloat {
    max(10, fontSize - 2)
  }
}
