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
  
  public var font: NSFont
  public var lineHeight: CGFloat
  public var renderingAttributes: AttributeContainer
  
  public var insertionPointColour: Color
  public var codeColour: Color
  public var hasLineNumbers: Bool
  public var isShowingFrames: Bool
  public var insets: CGFloat
  
  public init(
    font: NSFont = NSFont.systemFont(ofSize: 15),
    lineHeight: CGFloat = 1.3,
    renderingAttributes: AttributeContainer = .markdownRenderingDefaults,
    
    insertionPointColour: Color = .blue,
    codeColour: Color = .primary.opacity(0.7),
    hasLineNumbers: Bool = false,
    
    isShowingFrames: Bool = false,
    insets: CGFloat = 20
  ) {
    self.font = font
    self.lineHeight = lineHeight
    self.renderingAttributes = renderingAttributes
    
    self.insertionPointColour = insertionPointColour
    self.codeColour = codeColour
    self.hasLineNumbers = hasLineNumbers
    self.isShowingFrames = isShowingFrames
    self.insets = insets
  }
}

extension MarkdownEditorConfiguration {
  
  var defaultTypingAttributes: Attributes {
    
    let renderingAttributes: Attributes = self.renderingAttributes.getAttributes() ?? [:]
    
    let fontAttributes: Attributes = [.font: self.font]
    
    let allAttributes: Attributes = renderingAttributes.merging(fontAttributes) { currentValue, newValue in
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
    container.foregroundColor = NSColor.textColor

    return container
  }
  
//  static var markdownFontDefaults: AttributeContainer {
//    
//    let paragraphStyle = NSMutableParagraphStyle()
//    
//    paragraphStyle.lineHeightMultiple = MarkdownDefaults.lineHeightMultiplier
//    
//    var container = AttributeContainer()
//    
//    container.paragraphStyle = paragraphStyle
//    container.font = MarkdownDefaults.defaultFont
//    
//    return container
//    
//  }
//  
//  static var markdownFontDefaultsSmall: AttributeContainer {
//    
//    let paragraphStyle = NSMutableParagraphStyle()
//    
//    paragraphStyle.lineHeightMultiple = 1.1
//    
//    var container = AttributeContainer()
//    
//    container.paragraphStyle = paragraphStyle
//    container.font = NSFont.systemFont(ofSize: 13)
//    
//    return container
//    
//  }
}
