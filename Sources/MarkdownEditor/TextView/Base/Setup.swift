//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import BaseHelpers
import SwiftUI
import MarkdownModels

//import Highlightr

extension MarkdownTextView {

  func setUpTextView(_ config: MarkdownEditorConfiguration) {
    
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
