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
    
    
    DispatchQueue.main.async {
      self.parseAndStyleMarkdownLite(trigger: .appeared)
      
      self.styleElements(trigger: .appeared)
    }
    
    
  }
  
  
  func setupScrollObservation() {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScrollViewDidScroll),
      name: NSView.boundsDidChangeNotification,
      object: enclosingScrollView?.contentView
    )
    
    // Method 2: Using KVO
    //    scrollObservation = enclosingScrollView?.contentView.observe(\.bounds) { [weak self] (contentView, change) in
    //      self?.handleScrollViewDidScroll()
    //    }
  }
  
  
}
