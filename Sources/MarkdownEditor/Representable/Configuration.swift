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
  public var theme: MarkdownTheme
  public var lineHeight: CGFloat
  public var renderingAttributes: AttributeContainer
  
  public var hasLineNumbers: Bool
  public var isShowingFrames: Bool
  public var insets: CGFloat
  
  public init(
    isEditable: Bool = true,
    theme: MarkdownTheme = .default,
    lineHeight: CGFloat = 1.1,
    renderingAttributes: AttributeContainer = .markdownRenderingDefaults,
    
    hasLineNumbers: Bool = false,
    
    isShowingFrames: Bool = false,
    insets: CGFloat = 20
  ) {
    self.isEditable = isEditable
    self.theme = theme
    self.lineHeight = lineHeight
    self.renderingAttributes = renderingAttributes

    self.hasLineNumbers = hasLineNumbers
    self.isShowingFrames = isShowingFrames
    self.insets = insets
  }
}

extension MarkdownEditorConfiguration {
  
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
