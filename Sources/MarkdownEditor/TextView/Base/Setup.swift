//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import BaseHelpers
import SwiftUI


extension MarkdownTextView {

  func setUpTextView(_ config: EditorConfiguration) {

    isEditable = config.isEditable
    drawsBackground = false
    isRichText = false
    allowsUndo = true
    
    isVerticallyResizable = true
    isHorizontallyResizable = false
    
    let max = CGFloat.greatestFiniteMagnitude

    minSize = NSSize.zero
    maxSize = NSSize(width: max, height: max)
    
    isAutomaticDashSubstitutionEnabled = false
    
    autoresizingMask = [.width]
    
    textContainer?.widthTracksTextView = true
    textContainer?.heightTracksTextView = false
    
    textContainer?.lineFragmentPadding = config.theme.insets
    textContainerInset = NSSize(
      width: 0,
      height: config.theme.insets
    )
    font = NSFont.systemFont(
      ofSize: config.theme.fontSize)
    
    typingAttributes = config.defaultTypingAttributes
    defaultParagraphStyle = config.defaultParagraphStyle
  }

}
