//
//  Theme.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/9/2024.
//

import SwiftUI

public struct MarkdownTheme: Sendable, Equatable {
  
  public var fontSize: CGFloat
  public var textColour: NSColor
  
  public var codeColour: Color
  public var codeBackgroundColour: Color
  
  public var lineHeight: CGFloat
  
  public var heading1Colour: Color
  public var heading2Colour: Color
  public var heading3Colour: Color
  
  public var insertionPointColour: Color
  
  public init(
    fontSize: CGFloat = 15,
    textColour: NSColor = .textColor.withAlphaComponent(0.9),
    
    codeColour: Color = .green,
    codeBackgroundColour: Color = .blue.opacity(0.4),
    
    lineHeight: CGFloat = 8,
    
    heading1Colour: Color = .indigo,
    heading2Colour: Color = .blue,
    heading3Colour: Color = .brown,
    insertionPointColour: Color = .purple
  ) {
    self.fontSize = fontSize
    self.textColour = textColour
    
    self.codeColour = codeColour
    self.codeBackgroundColour = codeBackgroundColour
    self.lineHeight = lineHeight
    
    self.heading1Colour = heading1Colour
    self.heading2Colour = heading2Colour
    self.heading3Colour = heading3Colour
    
    self.insertionPointColour = insertionPointColour
  }
  
  
}

public extension MarkdownTheme {
  
  static var `default`: MarkdownTheme {
    .init()
  }
  
  
  
  var defaultFont: NSFont {
    return NSFont.systemFont(ofSize: self.fontSize)
  }
  
  var codeFont: NSFont {
    return NSFont.monospacedSystemFont(ofSize: self.fontSize - 1, weight: .medium)
  }
  
}
