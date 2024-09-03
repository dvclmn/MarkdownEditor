//
//  ScrollView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI



public class MarkdownScrollView: NSScrollView {
  
  var textView: MarkdownTextView!
  
  // MARK: - Initialization
  
  init(frame frameRect: NSRect, configuration: MarkdownEditorConfiguration) {
    super.init(frame: frameRect)
    
    let textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: configuration)
    
    self.textView = textView
    
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
    isFindBarVisible = false
    
    documentView = textView
  }
  

}



