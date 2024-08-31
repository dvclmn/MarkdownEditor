//
//  Configuration.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//


import Foundation
import SwiftUI

public struct MarkdownEditorConfiguration: Sendable, Equatable {
  
  public var attributes: AttributeContainer
  
  public var insertionPointColour: Color
  public var codeColour: Color
  public var hasLineNumbers: Bool
  public var isShowingFrames: Bool
  public var insets: CGFloat
  
  public init(
    attributes: AttributeContainer = .markdownEditorDefaults,
    
    insertionPointColour: Color = .blue,
    codeColour: Color = .primary.opacity(0.7),
    hasLineNumbers: Bool = false,
    
    isShowingFrames: Bool = false,
    insets: CGFloat = 20
  ) {
    self.attributes = attributes
    
    self.insertionPointColour = insertionPointColour
    self.codeColour = codeColour
    self.hasLineNumbers = hasLineNumbers
    self.isShowingFrames = isShowingFrames
    self.insets = insets
  }
}

public extension AttributeContainer {
  static var markdownEditorDefaults: AttributeContainer {
    
    
    let paragraphStyle = NSMutableParagraphStyle()
    
    // TODO: Obvs exaggerated value for testing
    paragraphStyle.lineHeightMultiple = MarkdownDefaults.lineHeightMultiplier
    
    var container = AttributeContainer()
    
    container.foregroundColor = NSColor.textColor
    container.paragraphStyle = paragraphStyle
    container.font = MarkdownDefaults.defaultFont
    
    return container
    
  }
}
