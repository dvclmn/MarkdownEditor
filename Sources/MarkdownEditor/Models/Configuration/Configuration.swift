//
//  Configuration.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//

import Foundation
import SwiftUI
import BaseHelpers

public struct EditorConfiguration: Sendable, Equatable {
  
  public var isEditable: Bool = false
  public var theme: MarkdownTheme = .default

  public var isShowingFrames: Bool = false
  
  public init(
    isEditable: Bool = true,
    theme: MarkdownTheme = .default,
    isShowingFrames: Bool = false
  ) {
    self.isEditable = isEditable
    self.theme = theme
    self.isShowingFrames = isShowingFrames
  }

  /// Convenience initializer from options
  public init(options: [Option]) {
    var theme = MarkdownTheme.default
    
    if options.contains(.isEditable) {
      self.isEditable = true
    }
    
    if options.contains(.showingFrames) {
      self.isShowingFrames = true
    }
    
    if options.contains(.hasOverScroll) {
      theme.overScrollAmount = 60
    }
    
    if options.contains(.isFullWidth) {
      theme.maxReadingWidth = nil
    }
    
    self.theme = theme
  }

}

extension EditorConfiguration {
  
  public struct Option: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    public static let isEditable = Option(rawValue: 1 << 0)
    public static let showingFrames = Option(rawValue: 1 << 1)
    public static let hasOverScroll = Option(rawValue: 1 << 2)
    public static let isFullWidth = Option(rawValue: 1 << 3)
  }
}


extension EditorConfiguration {
  
  public var codeBlockPadding: CGFloat {
    theme.insets * 0.4
  }
  
  public var defaultTypingAttributes: Attributes {
    return [
      .font: defaultFont,
      .foregroundColor: theme.textColour.nsColour,
      .paragraphStyle: defaultParagraphStyle,
      TextBackground.inlineCode.attributeKey: false,
      TextBackground.codeBlock.attributeKey: false,
      TextBackground.highlight.attributeKey: false,
    ]
  }
  
  public var defaultParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = self.theme.lineHeight
    
    return paragraphStyle
  }
}

public enum TextBackground: CaseIterable {
  
  case inlineCode
  case codeBlock
  case highlight
  
  public var attributeKey: NSAttributedString.Key {
    switch self {
      case .inlineCode: NSAttributedString.Key("inlineCode")
      case .codeBlock: NSAttributedString.Key("codeBlock")
      case .highlight: NSAttributedString.Key("highlight")
    }
  }
  
  public var insets: (dx: CGFloat, dy: CGFloat) {
    switch self {
      case .inlineCode, .codeBlock, .highlight:
        (-2, -1)
    }
  }
  
  public func fillColour(from configuration: EditorConfiguration) -> Color {
    switch self {
      case .inlineCode: configuration.theme.inlineCodeBackgroundColour
      case .codeBlock: configuration.theme.codeBlockBackgroundColour
      case .highlight: configuration.theme.highlightBackground
    }
  }
}
