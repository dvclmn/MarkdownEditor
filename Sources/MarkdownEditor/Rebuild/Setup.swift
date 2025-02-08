//
//  Setup.swift
//  Components
//
//  Created by Dave Coleman on 8/2/2025.
//

import AppKit

extension AutoSizingTextView {
  
  func setUpTextView(_ config: EditorConfig) {
    
    isEditable = config.isEditable
    drawsBackground = false
    
    isVerticallyResizable = true
    isHorizontallyResizable = false
    
    autoresizingMask = [.width]
    
    textContainer?.widthTracksTextView = true
    textContainer?.heightTracksTextView = false
    
    textContainer?.lineFragmentPadding = config.insets
    textContainerInset = NSSize(
      width: 0,
      height: config.insets
    )
    font = NSFont.systemFont(
      ofSize: config.theme.fontSize)

    defaultParagraphStyle = config.defaultParagraphStyle
    
    /// Add default attribute for inline code
    var attrs = config.defaultTypingAttributes
    attrs[.inlineCode] = false
    typingAttributes = attrs
  }
  
}
