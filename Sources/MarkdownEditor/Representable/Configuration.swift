//
//  Configuration.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//


import Foundation
import SwiftUI
import TextCore

public struct MarkdownEditorConfiguration: Sendable, Equatable {
  
  public var isEditable: Bool
  public var isScrollable: Bool
  public var theme: MarkdownTheme
  public var lineHeight: CGFloat
  public var renderingAttributes: AttributeContainer
  public var bottomSafeArea: CGFloat
  public var hasLineNumbers: Bool
  public var isShowingFrames: Bool
  public var maxReadingWidth: CGFloat
  
//  let isTextKit2: Bool = false
  
  /// I've been switching Neon on and off a lot, so this is here to save me
  /// constantly toggling blocks of code everywhere.
  public var insets: CGFloat
  
  var isNeonEnabled: Bool
  
  public init(
    isEditable: Bool = true,
    isScrollable: Bool = false,
    theme: MarkdownTheme = .default,
    lineHeight: CGFloat = 1.1,
    renderingAttributes: AttributeContainer = .markdownRenderingDefaults,
    bottomSafeArea: CGFloat = .zero,
    hasLineNumbers: Bool = false,
    
    isShowingFrames: Bool = false,
    insets: CGFloat = 20,
    isNeonEnabled: Bool = true,
    maxReadingWidth: CGFloat = 580
  ) {
    self.isEditable = isEditable
    self.isScrollable = isScrollable
    self.theme = theme
    self.lineHeight = lineHeight
    self.renderingAttributes = renderingAttributes
    self.bottomSafeArea = bottomSafeArea
    self.hasLineNumbers = hasLineNumbers
    self.isShowingFrames = isShowingFrames
    self.insets = insets
    self.isNeonEnabled = isNeonEnabled
    self.maxReadingWidth = maxReadingWidth
  }
}

extension MarkdownEditorConfiguration {
  
  var codeBlockPadding: CGFloat {
    self.insets * 0.4
  }
  
  var defaultTypingAttributes: Attributes {
    
    let renderingAttributes: Attributes = self.renderingAttributes.getAttributes() ?? [:]
    
    let font = NSFont.systemFont(ofSize: self.theme.fontSize)
    let paragraphStyle = defaultParagraphStyle
    let fontAttributes: Attributes = [
      .font: font,
      .paragraphStyle: paragraphStyle
    ]
    
    let allAttributes: Attributes = renderingAttributes.merging(fontAttributes) { _, _ in
      return true
    }
    
    return allAttributes
  }
  
  var defaultParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = self.lineHeight
//    paragraphStyle.lineSpacing = 30
    
    return paragraphStyle
  }
}

public extension AttributeContainer {
  static var markdownRenderingDefaults: AttributeContainer {
    var container = AttributeContainer()
    container.foregroundColor = NSColor.textColor.withAlphaComponent(0.9)

    return container
  }
}
