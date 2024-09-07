//
//  ScrollView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI


public class MarkdownScrollView: NSScrollView {
  
  let configuration: MarkdownEditorConfiguration
  
  // MARK: - Initialization
  
  init(frame frameRect: NSRect, configuration: MarkdownEditorConfiguration) {
    self.configuration = configuration
    super.init(frame: frameRect)
    
    setupScrollView()
  }
  
  required init?(coder: NSCoder) {
    assertionFailure("This init not supported")
    self.configuration = MarkdownEditorConfiguration.init()
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
    
    let textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: configuration)
    
    self.documentView = textView
    
    self.hasVerticalScroller = true
    self.hasHorizontalScroller = false
    self.autohidesScrollers = true
    self.drawsBackground = false
    
    self.autoresizingMask = [.width, .height]
    
//    scrollView.translatesAutoresizingMaskIntoConstraints = false
//    
//    scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//    scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//    scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//    scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//
    
    contentView.postsBoundsChangedNotifications = true
    
    NotificationCenter.default.addObserver(self, selector: #selector(boundsDidChange(_:)), name: NSView.boundsDidChangeNotification, object: contentView)
    
  }
  
  @objc private func boundsDidChange(_ notification: Notification) {
    let newOffset = CGPoint(x: horizontalScrollOffset, y: verticalScrollOffset)
    scrollOffsetDidChange?(newOffset)
  }
  
  
  
}



