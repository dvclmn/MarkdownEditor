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
  
  func applyConfiguration() {
    
    self.font = NSFont.systemFont(ofSize: self.configuration.fontSize)
    self.defaultParagraphStyle = self.configuration.defaultParagraphStyle
    self.insertionPointColor = NSColor(self.configuration.insertionPointColour)
    
    textContainer?.lineFragmentPadding = self.configuration.insets
    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    
    typingAttributes = self.configuration.defaultTypingAttributes
    defaultParagraphStyle = self.configuration.defaultParagraphStyle
    
  }

  func textViewSetup() {
    
    isEditable = true
    drawsBackground = false
    allowsUndo = true
    isRichText = false
    
    isVerticallyResizable = true
    isHorizontallyResizable = false
    
    smartInsertDeleteEnabled = false
    
//    autoresizingMask = [.width]
    autoresizingMask = [.width, .height]
    
    textContainer?.widthTracksTextView = true
    textContainer?.heightTracksTextView = false
    
    let containerSize = self.enclosingScrollView?.frame.size ?? .zero
    textLayoutManager?.textContainer?.containerSize = containerSize

    wrapsTextToHorizontalBounds = true

    
    self.applyConfiguration()
  }
}


/// Credit: https://github.com/ChimeHQ/TextViewPlus
///
extension NSTextView {
  private var maximumUsableWidth: CGFloat {
    guard let scrollView = enclosingScrollView else {
      return bounds.width
    }
    
    let usableWidth = scrollView.contentSize.width - textContainerInset.width
    
    guard scrollView.rulersVisible, let rulerView = scrollView.verticalRulerView else {
      return usableWidth
    }
    
    return usableWidth - rulerView.requiredThickness
  }
  
  /// Controls the relative sizing behavior of the NSTextView and its NSTextContainer
  ///
  /// NSTextView size changes/scrolling behavior is tricky. This adjusts:
  /// - `textContainer.widthTracksTextView`
  /// - `textContainer?.size`: to allow unlimited height/width growth
  /// - `maxSize`: to allow unlimited height/width growth
  /// - `frame`: to account for `NSScrollView` rulers
  ///
  /// Check out: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
  public var wrapsTextToHorizontalBounds: Bool {
    get {
      guard let container = textContainer else {
        return false
      }
      
      return container.widthTracksTextView
    }
    set {
      textContainer?.widthTracksTextView = newValue
      
      let max = CGFloat.greatestFiniteMagnitude
      let size = NSSize(width: max, height: max)
      
      textContainer?.size = size
      maxSize = size

      if newValue {
        let newSize = NSSize(width: maximumUsableWidth, height: frame.height)
        
        self.frame = NSRect(origin: frame.origin, size: newSize)
      }
    }
  }
}
