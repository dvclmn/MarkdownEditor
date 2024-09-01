//
//  Changed+Appeared.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  public override func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    
    setupScrollObservation()
  }
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    
    setupViewportLayoutController()
    
        onAppearAndTextChange()
    
    
  }
  
  private func setupScrollObservation() {
    // Method 1: Using NSNotification
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScrollViewDidScroll),
      name: NSView.boundsDidChangeNotification,
      object: enclosingScrollView?.contentView
    )
    
    // Method 2: Using KVO
    scrollObservation = enclosingScrollView?.contentView.observe(\.bounds) { [weak self] (contentView, change) in
      self?.handleScrollViewDidScroll()
    }
  }
  
  @objc private func handleScrollViewDidScroll() {
    guard let scrollView = enclosingScrollView else { return }
    
    
    // Your custom code here
    // For example:
    // updateVisibleRange()
    // refreshSyntaxHighlighting()
    // etc.
    
    
//    let verticalOffset = scrollView.contentView.bounds.origin.y
//    print("Scroll offset updated: \(verticalOffset)")
    
    // Update visible range
//    if let layoutManager = self.layoutManager,
//       let container = self.textContainer {
//      let visibleRect = self.visibleRect
//      let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: container)
//      let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
//      
//      print("Visible character range: \(characterRange)")
//      
      // Do something with the visible range
      // For example, update syntax highlighting for visible text
      // updateSyntaxHighlighting(for: characterRange)
//    }

  }
  
  
  
}
