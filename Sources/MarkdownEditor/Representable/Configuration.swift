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

  public var bottomSafeArea: CGFloat
  public var hasLineNumbers: Bool
  public var isShowingFrames: Bool
  public var maxReadingWidth: CGFloat
  
  
  /// I've been switching Neon on and off a lot, so this is here to save me
  /// constantly toggling blocks of code everywhere.
  public var insets: CGFloat
  
#if DEBUG
  
  let neonConfig: NeonConfiguration = .textViewHighlighter
  let drawsCodeBlockBackgrounds: Bool = false
  let isHandlingKeyPress: Bool = true
  let isSendingEditorHeight: Bool = false
  
  let isDebugFragmentsMode: Bool = true
  
  let isParsing: Bool = false
  let isStyling: Bool = true


#endif
  
  public init(
    isEditable: Bool = true,
    isScrollable: Bool = false,
    theme: MarkdownTheme = .default,

    bottomSafeArea: CGFloat = .zero,
    hasLineNumbers: Bool = false,
    
    isShowingFrames: Bool = false,
    insets: CGFloat = 20,
    maxReadingWidth: CGFloat = 580
  ) {
    self.isEditable = isEditable
    self.isScrollable = isScrollable
    self.theme = theme

    self.bottomSafeArea = bottomSafeArea
    self.hasLineNumbers = hasLineNumbers
    self.isShowingFrames = isShowingFrames
    self.insets = insets
    self.maxReadingWidth = maxReadingWidth
  }
}

enum NeonConfiguration {
  case textViewHighlighter
  case manual // Not yet implemented
  case none
}

extension MarkdownEditorConfiguration {
  
  var codeBlockPadding: CGFloat {
    self.insets * 0.4
  }
  
  var defaultTypingAttributes: Attributes {
    
    let font = NSFont.systemFont(ofSize: self.theme.fontSize)
    
    let textColour = self.theme.textColour
    
    let paragraphStyle = defaultParagraphStyle
    
    let attributes: Attributes = [
      .font: font,
      .foregroundColor: textColour,
      .paragraphStyle: paragraphStyle
    ]
    
    return attributes
  }
  
  var defaultParagraphStyle: NSParagraphStyle {
    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.lineHeightMultiple = self.lineHeight
    paragraphStyle.lineSpacing = self.theme.lineHeight
    
    return paragraphStyle
  }
}

public extension AttributeContainer {
  
//  static var markdownRenderingDefaults: AttributeContainer {
//    var container = AttributeContainer()
//    container.foregroundColor = NSColor.textColor.withAlphaComponent(0.9)
//
//    return container
//  }
}
