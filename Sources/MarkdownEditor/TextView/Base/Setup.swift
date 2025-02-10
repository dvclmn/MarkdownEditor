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
    
    allowsUndo = true
    
    isVerticallyResizable = true
    isHorizontallyResizable = false
    
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
