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
//    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    
    
    
//    standard.titleTextAttributes = try? Dictionary(container, including: \.uiKit)
    
    
    
    
    
    font = NSFont.systemFont(ofSize: 15, weight: .regular)
    textColor = NSColor.textColor
    
    let paragraphStyle = NSMutableParagraphStyle()
    
    // TODO: Obvs exaggerated value for testing
    paragraphStyle.lineHeightMultiple = 2.2
    
    var attributes = AttributeContainer()
    attributes.foregroundColor = NSColor.textColor
    attributes.paragraphStyle = paragraphStyle
    attributes.font = NSFont.systemFont(ofSize: 15, weight: NSFont.Weight.init(0.0))
    
//    typingAttributes = attributes.getAttributes() ?? [:]
    defaultParagraphStyle = paragraphStyle

  }
}
