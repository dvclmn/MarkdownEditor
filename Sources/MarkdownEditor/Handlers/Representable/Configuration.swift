//
//  Configuration.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 21/8/2024.
//


import Foundation
import SwiftUI

public struct MarkdownEditorConfiguration: Sendable {
  public var fontSize: Double
  public var fontWeight: NSFont.Weight
  public var insertionPointColour: Color
  public var codeColour: Color
  public var paddingX: Double
  public var paddingY: Double
  
  public init(
    fontSize: Double = MarkdownDefaults.fontSize,
    fontWeight: NSFont.Weight = MarkdownDefaults.fontWeight,
    insertionPointColour: Color = .blue,
    codeColour: Color = .primary.opacity(0.7),
    paddingX: Double = MarkdownDefaults.paddingX,
    paddingY: Double = MarkdownDefaults.paddingY
  ) {
    self.fontSize = fontSize
    self.fontWeight = fontWeight
    self.insertionPointColour = insertionPointColour
    self.codeColour = codeColour
    self.paddingX = paddingX
    self.paddingY = paddingY
  }
}

