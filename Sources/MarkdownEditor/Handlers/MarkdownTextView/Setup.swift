//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI


extension MarkdownTextView {
  func textViewSetup() {
    
    self.smartInsertDeleteEnabled = false
    self.autoresizingMask = .width
    self.textContainer?.widthTracksTextView = true
    self.textContainer?.heightTracksTextView = false
    self.drawsBackground = false
    self.isHorizontallyResizable = false
    self.isVerticallyResizable = true
    self.allowsUndo = true
    self.isRichText = false
    self.textContainer?.lineFragmentPadding = 30
    self.textContainerInset = NSSize(width: 0, height: 30)
    self.font = NSFont.systemFont(ofSize: 15, weight: .regular)
    self.textColor = NSColor.textColor
    //    self.textContainerInset = CGSize(width: 5.0, height: 5.0)
  }
}
