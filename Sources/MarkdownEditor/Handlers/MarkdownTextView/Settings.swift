//
//  Settings.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 13/8/2024.
//

import SwiftUI


// TODO: This should actually be in the MarkdownView folder, not text view
extension MarkdownView {
  
  
  /// A Boolean that controls whether the text container adjusts the width of its bounding rectangle when its text view resizes.
  ///
  /// When the value of this property is `true`, the text container adjusts its width when the width of its text view changes. The default value of this property is `false`.
  ///
  /// - Note: If you set both `widthTracksTextView` and `isHorizontallyResizable` up to resize automatically in the same dimension, your application can get trapped in an infinite loop.
  ///
  /// - SeeAlso: [Tracking the Size of a Text View](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextStorageLayer/Tasks/TrackingSize.html#//apple_ref/doc/uid/20000927-CJBBIAAF)
  public var widthTracksTextView: Bool {
    set {
      if textContainer.widthTracksTextView != newValue {
        textContainer.widthTracksTextView = newValue
        textContainer.size = NSTextContainer().size
//        if let clipView = scrollView?.contentView as? NSClipView {
//          frame.size.width = clipView.bounds.size.width - clipView.contentInsets.horizontalInsets
//        }
        needsLayout = true
        needsDisplay = true
      }
    }
    
    get {
      textContainer.widthTracksTextView
    }
  }
  
  /// A Boolean that controls whether the receiver changes its width to fit the width of its text.
  public var isHorizontallyResizable: Bool {
    set {
      widthTracksTextView = newValue
    }
    
    get {
      widthTracksTextView
    }
  }
  
  /// A Boolean that controls whether the text container adjusts the height of its bounding rectangle when its text view resizes.
  ///
  /// When the value of this property is `true`, the text container adjusts its height when the height of its text view changes. The default value of this property is `false`.
  ///
  /// - Note: If you set both `heightTracksTextView` and `isVerticallyResizable` up to resize automatically in the same dimension, your application can get trapped in an infinite loop.
  ///
  /// - SeeAlso: [Tracking the Size of a Text View](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextStorageLayer/Tasks/TrackingSize.html#//apple_ref/doc/uid/20000927-CJBBIAAF)
  public var heightTracksTextView: Bool {
    set {
      if textContainer.heightTracksTextView != newValue {
        textContainer.heightTracksTextView = newValue
        
        textContainer.size = NSTextContainer().size
//        if let clipView = scrollView?.contentView as? NSClipView {
//          frame.size.height = clipView.bounds.size.height - clipView.contentInsets.verticalInsets
//        }
        
        needsLayout = true
        needsDisplay = true
      }
    }
    
    get {
      textContainer.heightTracksTextView
    }
  }
  
  /// A Boolean that controls whether the receiver changes its height to fit the height of its text.
  public var isVerticallyResizable: Bool {
    set {
      heightTracksTextView = newValue
    }
    
    get {
      heightTracksTextView
    }
  }

  
  
}
