//
//  Configuration.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//


import Foundation
import SwiftUI

public struct MarkdownEditorConfiguration: Sendable, Equatable {
  public var fontSize: Double
  public var fontWeight: NSFont.Weight
  public var insertionPointColour: Color
  public var codeColour: Color
  public var hasLineNumbers: Bool
  public var isShowingFrames: Bool
  public var insets: CGFloat
  
  public init(
    fontSize: Double = MarkdownDefaults.fontSize,
    fontWeight: NSFont.Weight = MarkdownDefaults.fontWeight,
    insertionPointColour: Color = .blue,
    codeColour: Color = .primary.opacity(0.7),
    hasLineNumbers: Bool = false,
    isShowingFrames: Bool = false,
    insets: CGFloat = 20
  ) {
    self.fontSize = fontSize
    self.fontWeight = fontWeight
    self.insertionPointColour = insertionPointColour
    self.codeColour = codeColour
    self.hasLineNumbers = hasLineNumbers
    self.isShowingFrames = isShowingFrames
    self.insets = insets
  }
}

