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

extension MarkdownViewController {
  func setUpScrollView() {
    scrollView.hasVerticalScroller = true
    scrollView.drawsBackground = false
    scrollView.documentView = textView
    scrollView.additionalSafeAreaInsets.bottom = 40
  }
}

extension MarkdownTextView {

  func textViewSetup() {
    
    isEditable = true
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

    self.applyConfiguration()
  }
  
  
  func applyConfiguration() {
    
    self.insertionPointColor = NSColor(self.configuration.insertionPointColour)
    //
    textContainer?.lineFragmentPadding = self.configuration.insets
    textContainerInset = NSSize(width: 0, height: self.configuration.insets)
    //
        typingAttributes = self.configuration.defaultTypingAttributes
    
    
  }

  
}

//
///// Credit: https://github.com/ChimeHQ/TextViewPlus
/////
//extension NSTextView {
//  private var maximumUsableWidth: CGFloat {
//    guard let scrollView = enclosingScrollView else {
//      return bounds.width
//    }
//    
//    let usableWidth = scrollView.contentSize.width - textContainerInset.width
//    
//    guard scrollView.rulersVisible, let rulerView = scrollView.verticalRulerView else {
//      return usableWidth
//    }
//    
//    return usableWidth - rulerView.requiredThickness
//  }
//  
//  /// Controls the relative sizing behavior of the NSTextView and its NSTextContainer
//  ///
//  /// NSTextView size changes/scrolling behavior is tricky. This adjusts:
//  /// - `textContainer.widthTracksTextView`
//  /// - `textContainer?.size`: to allow unlimited height/width growth
//  /// - `maxSize`: to allow unlimited height/width growth
//  /// - `frame`: to account for `NSScrollView` rulers
//  ///
//  /// Check out: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
//  public var wrapsTextToHorizontalBounds: Bool {
//    get {
//      guard let container = textContainer else {
//        return false
//      }
//      
//      return container.widthTracksTextView
//    }
//    set {
//      textContainer?.widthTracksTextView = newValue
//      
//      let max = CGFloat.greatestFiniteMagnitude
//      let size = NSSize(width: max, height: max)
//      
//      textContainer?.size = size
//      maxSize = size
//
//      if newValue {
//        let newSize = NSSize(width: maximumUsableWidth, height: frame.height)
//        
//        self.frame = NSRect(origin: frame.origin, size: newSize)
//      }
//    }
//  }
//}
