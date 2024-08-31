//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI

extension AttributeContainer {
  
  func getAttributes<S: AttributeScope>(for scope: KeyPath<AttributeScopes, S.Type>) -> [NSAttributedString.Key: Any]? {
    do {
      return try Dictionary(self, including: scope)
    } catch {
      return nil
    }
  }

  /// Overload, to allow `\.appKit` as default
  func getAttributes() -> [NSAttributedString.Key: Any]? {
    return getAttributes(for: \.appKit)
  }
}

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
    
    let renderingAttributes = self.configuration.renderingAttributes
    let fontAttributes = self.configuration.fontAttributes

    typingAttributes = renderingAttributes.getAttributes() ?? [:]
    defaultParagraphStyle = fontAttributes.paragraphStyle

  }
}
