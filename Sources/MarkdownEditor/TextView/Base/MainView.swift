//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/2/2025.
//

import AppKit
import MarkdownModels

public class MarkdownScrollView: NSView {
  private let scrollView: NSScrollView
  private let textView: MarkdownTextView
  
  public init(
    frame frameRect: NSRect,
    configuration: EditorConfiguration
  ) {
    /// Create text storage and layout manager
    let textStorage = MarkdownTextStorage(configuration: configuration)
    let layoutManager = MarkdownLayoutManager(configuration: configuration)
    textStorage.addLayoutManager(layoutManager)
    
    /// Create text container
    let textContainer = NSTextContainer(
      containerSize: NSSize(
        width: frameRect.width,
        height: .greatestFiniteMagnitude
      )
    )
    textContainer.widthTracksTextView = true
    layoutManager.addTextContainer(textContainer)
    
    /// Create text view
    textView = MarkdownTextView(
      frame: frameRect,
      textContainer: textContainer,
      configuration: configuration
    )
    
    /// Create scroll view
    scrollView = NSScrollView(frame: frameRect)
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    
    /// Configure scroll view
    scrollView.documentView = textView
    
    super.init(frame: frameRect)
    
    /// Add scroll view as a subview
    addSubview(scrollView)
    
    // Set up constraints
//    scrollView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      scrollView.topAnchor.constraint(equalTo: topAnchor),
//      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
//      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
//    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Expose text view for additional configuration if needed
  public func getTextView() -> MarkdownTextView {
    return textView
  }
}



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
  /// `NSTextView` scrolling behavior is tricky. Correct configuration of the enclosing
  /// `NSScrollView` is required as well. But, this method does the basic setup,
  /// as well as adjusting frame positions to account for any `NSScrollView` rulers.
  ///
  /// Check out: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/TextUILayer/Tasks/TextInScrollView.html
  public var wrapsTextToHorizontalBounds: Bool {
    get {
      textContainer?.widthTracksTextView ?? false
    }
    set {
      textContainer?.widthTracksTextView = newValue
      
      let max = CGFloat.greatestFiniteMagnitude
      
      textContainer?.size = NSSize(width: max, height: max)
      
      // if we are turning on wrapping, our view could be the wrong size,
      // so need to adjust it. Also, the textContainer's width could have
      // been set too large, but adjusting the frame will fix that
      // automatically
      if newValue {
        let newSize = NSSize(width: maximumUsableWidth, height: frame.height)
        
        self.frame = NSRect(origin: frame.origin, size: newSize)
      }
    }
  }
}
