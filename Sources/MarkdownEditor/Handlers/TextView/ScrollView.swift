//
//  ScrollView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

/// Credit: https://github.com/ChimeHQ/TextViewPlus
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
      
      // if we are turning on wrapping, our view could be the wrong size,
      // so need to adjust it. Also, the textContainer's width could have
      // been set to large, but adjusting the frame will fix that
      // automatically
      if newValue {
        let newSize = NSSize(width: maximumUsableWidth, height: frame.height)
        
        self.frame = NSRect(origin: frame.origin, size: newSize)
      }
    }
  }
}



public class MarkdownScrollView: NSScrollView {
  
  // MARK: - Properties
  
  /// The current vertical scroll offset
  var verticalScrollOffset: CGFloat {
    return contentView.bounds.origin.y
  }
  
  /// The current horizontal scroll offset
  var horizontalScrollOffset: CGFloat {
    return contentView.bounds.origin.x
  }
  
  /// The total height of the content
  var contentHeight: CGFloat {
    return documentView?.frame.height ?? 0
  }
  
  /// The total width of the content
  var contentWidth: CGFloat {
    return documentView?.frame.width ?? 0
  }
  
  /// Closure to be called when scroll offset changes
  var scrollOffsetDidChange: ((CGPoint) -> Void)?
  
  // MARK: - Initialization
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupScrollView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupScrollView()
  }
  
  private func setupScrollView() {
    hasVerticalScroller = true
    hasHorizontalScroller = false
    autohidesScrollers = true
    drawsBackground = false
    isFindBarVisible = true
    
    
  }
  
  // MARK: - Scroll Control Methods
  
  /// Scroll to a specific offset
  /// - Parameters:
  ///   - point: The point to scroll to
  ///   - animated: Whether to animate the scrolling
  func scrollTo(point: CGPoint, animated: Bool) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = animated ? 0.3 : 0
      self.contentView.animator().setBoundsOrigin(point)
    }, completionHandler: nil)
  }
  
  /// Scroll to the top of the content
  /// - Parameter animated: Whether to animate the scrolling
  func scrollToTop(animated: Bool = true) {
    scrollTo(point: CGPoint(x: horizontalScrollOffset, y: 0), animated: animated)
  }
  
  /// Scroll to the bottom of the content
  /// - Parameter animated: Whether to animate the scrolling
  func scrollToBottom(animated: Bool = true) {
    let maxY = max(0, contentHeight - bounds.height)
    scrollTo(point: CGPoint(x: horizontalScrollOffset, y: maxY), animated: animated)
  }
  
  // MARK: - NSScrollView Overrides
  
  public override func scrollWheel(with event: NSEvent) {
    super.scrollWheel(with: event)
    
    // Notify about scroll offset change
    scrollOffsetDidChange?(contentView.bounds.origin)
  }
  
  public override func viewDidEndLiveResize() {
    super.viewDidEndLiveResize()
    
    // Notify about possible scroll offset change after resize
    scrollOffsetDidChange?(contentView.bounds.origin)
  }
  
  // MARK: - Custom Methods
  
  /// Add constraints to make the document view match the clip view's bounds
  //  func setupDocumentViewConstraints() {
  //
  //    guard let documentView = documentView else { return }
  //
  //    documentView.translatesAutoresizingMaskIntoConstraints = false
  //
  //    NSLayoutConstraint.activate([
  //      documentView.topAnchor.constraint(equalTo: contentView.topAnchor),
  //      documentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
  //      documentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
  //      documentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
  //    ])
  //  }
  // MARK: - Additional Custom Methods
  
  /// Set the scroll offset programmatically
  /// - Parameter offset: The new scroll offset
  func setScrollOffset(_ offset: CGPoint) {
    contentView.scroll(to: offset)
    reflectScrolledClipView(contentView)
  }
  
  /// Get the visible rect of the content
  public override var visibleRect: CGRect {
    guard let documentView = documentView else { return .zero }
    return documentView.visibleRect
  }
  
  /// Check if a specific rect is visible in the scroll view
  /// - Parameter rect: The rect to check
  /// - Returns: True if the rect is fully visible, false otherwise
  func isRectVisible(_ rect: CGRect) -> Bool {
    return visibleRect.contains(rect)
  }
  
  /// Scroll to make a specific rect visible
  /// - Parameters:
  ///   - rect: The rect to make visible
  ///   - animated: Whether to animate the scrolling
  func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = animated ? 0.3 : 0
      self.contentView.animator().scrollToVisible(rect)
    }, completionHandler: nil)
  }
  
  /// Get the current zoom scale
  var zoomScale: CGFloat {
    return magnification
  }
  
  /// Set the zoom scale
  /// - Parameters:
  ///   - scale: The new zoom scale
  ///   - animated: Whether to animate the zoom change
  func setZoomScale(_ scale: CGFloat, animated: Bool) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = animated ? 0.3 : 0
      self.animator().magnification = scale
    }, completionHandler: nil)
  }
  
  /// Add a shadow to the scroll view
  func addShadow(color: NSColor = .black, opacity: Float = 0.5, radius: CGFloat = 5) {
    wantsLayer = true
    layer?.shadowColor = color.cgColor
    layer?.shadowOpacity = opacity
    layer?.shadowRadius = radius
    layer?.shadowOffset = .zero
    layer?.masksToBounds = false
  }
}



