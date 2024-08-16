//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI


extension MarkdownTextView {
  func textViewSetup() {
    
    isEditable = true
    drawsBackground = false
    allowsUndo = true
    isRichText = false
    
    isVerticallyResizable = true
    isHorizontallyResizable = true
    wrapsTextToHorizontalBounds = true
    
    smartInsertDeleteEnabled = false
    
    autoresizingMask = [.width, .height]
    textContainer?.widthTracksTextView = true
    textContainer?.heightTracksTextView = false
    
    textContainer?.lineFragmentPadding = self.configuration.insets
    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    
    font = NSFont.systemFont(ofSize: 15, weight: .regular)
    textColor = NSColor.textColor
  }
}
