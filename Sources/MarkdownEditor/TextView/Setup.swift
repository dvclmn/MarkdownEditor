//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI
import TextCore

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
    
    isEditable = self.configuration.isEditable
    
    isSelectable = true
    drawsBackground = false
    allowsUndo = true
    isRichText = false
    
    let max = CGFloat.greatestFiniteMagnitude
    
    minSize = NSSize.zero
    maxSize = NSSize(width: max, height: max)
    
    isVerticallyResizable = true
    isHorizontallyResizable = true
    
    smartInsertDeleteEnabled = false
    
    autoresizingMask = [.width, .height]
    
    textContainer?.widthTracksTextView = true
    textContainer?.heightTracksTextView = false
    
    if !configuration.isScrollable {
      textContainer?.containerSize = NSSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
    }


    self.applyConfiguration()
  }
  
  
  func applyConfiguration() {
    
    self.insertionPointColor = NSColor(self.configuration.theme.insertionPointColour)
    //
    textContainer?.lineFragmentPadding = self.configuration.insets
    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    
    self.font = NSFont.systemFont(ofSize: self.configuration.theme.fontSize)
    
    //
//        typingAttributes = self.configuration.defaultTypingAttributes
    
//    let defaultAttributes: Attributes = [.foregroundColor: NSColor.textColor.withAlphaComponent(0.9)]
    
//    let defaults = self.configuration.defaultTypingAttributes
    
//    let nsString = self.string as NSString
    
    self.defaultParagraphStyle = self.configuration.defaultParagraphStyle
    
//    self.textStorage?.setAttributes(defaults, range: NSRange(location: 0, length: nsString.length))
    
    
  }

  
}
