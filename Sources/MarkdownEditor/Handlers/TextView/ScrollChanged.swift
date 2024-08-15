//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  public override func viewDidMoveToWindow() {
    
    super.viewDidMoveToWindow()
    
    if let info = self.calculateTextInfo() {
      self.onTextChange(info)
    }
    self.onEditorHeightChange(self.editorHeight)
    
    setupViewportLayoutController()
    
    self.testStyles()
    
    self.markdownBlocks = self.processMarkdownBlocks(highlight: true)

  }

  
}

actor ScrollHandler {
  private var timer: Timer?
  private(set) var lastScrollOffset: CGFloat = .zero
  private var onScrollChange: ((EditorInfo.Scroll) -> Void)?
  
  func updateScrollOffset(_ newOffset: CGFloat, onScrollChange: @escaping (EditorInfo.Scroll) -> Void) {
    if newOffset != lastScrollOffset {
      lastScrollOffset = newOffset
      self.onScrollChange = onScrollChange
      debounceScrollChange()
    }
  }
  
  private func debounceScrollChange() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
      Task { [weak self] in
        await self?.processScrollChange()
      }
    }
  }
  
  private func processScrollChange() {
    // Here you can perform any calculations needed for EditorInfo.Scroll
    let scrollInfo = EditorInfo.Scroll(summary: "Scrolled to offset: \(lastScrollOffset)")
    onScrollChange?(scrollInfo)
  }
  
  deinit {
    timer?.invalidate()
  }
}

