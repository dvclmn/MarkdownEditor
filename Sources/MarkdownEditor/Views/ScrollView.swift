//
//  ScrollView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI



public class MarkdownScrollView: NSScrollView {
  
  var textView: MarkdownTextView!
  var lineNumberView: LineNumberView!
  
  // MARK: - Initialization
  
  override init(frame frameRect: NSRect) {
    
    let textView = MarkdownTextView(frame: .zero, textContainer: nil)
    
    let lineNumbers = LineNumberView(scrollView: nil, orientation: .verticalRuler)
    
    self.textView = textView
    self.lineNumberView = lineNumbers
    
    super.init(frame: frameRect)
    setupScrollView()
  }
  
  required init?(coder: NSCoder) {
    assertionFailure("This init not supported")
    super.init(coder: coder)
  }
  
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
  
  
  
  private func setupScrollView() {
    
    hasVerticalScroller = true
    hasHorizontalScroller = false
    autohidesScrollers = true
    drawsBackground = false
    isFindBarVisible = true
    
    documentView = textView
    
    if textView.configuration.hasLineNumbers {
      lineNumberView.scrollView = self
      lineNumberView.clientView = textView
      
      // Set the ruler view
      verticalRulerView = lineNumberView
      rulersVisible = true
      
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSText.didChangeNotification, object: textView)
  }
  
  var lineNumbersWidth: CGFloat {
    
    var result: CGFloat
    
    if textView.configuration.hasLineNumbers {
      result = .zero
    } else {
      result = textView.configuration.insets - 10
    }
    
    return result
  }
  
  
  @objc private func textDidChange(_ notification: Notification) {
    lineNumberView.needsDisplay = true
  }
  
  public override func tile() {
    super.tile()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
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
  

  public override func viewDidEndLiveResize() {
    super.viewDidEndLiveResize()
    
    // Notify about possible scroll offset change after resize
    scrollOffsetDidChange?(contentView.bounds.origin)
  }
  

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
  //  func isRectVisible(_ rect: CGRect) -> Bool {
  //    return visibleRect.contains(rect)
  //  }
  
  /// Scroll to make a specific rect visible
  /// - Parameters:
  ///   - rect: The rect to make visible
  ///   - animated: Whether to animate the scrolling
  //  func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
  //    NSAnimationContext.runAnimationGroup({ context in
  //      context.duration = animated ? 0.3 : 0
  //      self.contentView.animator().scrollToVisible(rect)
  //    }, completionHandler: nil)
  //  }
  
  /// Get the current zoom scale
  //  var zoomScale: CGFloat {
  //    return magnification
  //  }
  
  /// Set the zoom scale
  /// - Parameters:
  ///   - scale: The new zoom scale
  ///   - animated: Whether to animate the zoom change
  //  func setZoomScale(_ scale: CGFloat, animated: Bool) {
  //    NSAnimationContext.runAnimationGroup({ context in
  //      context.duration = animated ? 0.3 : 0
  //      self.animator().magnification = scale
  //    }, completionHandler: nil)
  //  }
}



