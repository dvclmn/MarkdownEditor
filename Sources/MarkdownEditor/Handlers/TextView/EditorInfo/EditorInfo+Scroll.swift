//
//  File.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  func calculateScrollInfo() async -> EditorInfo.Scroll {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return .init() }
    
    let visibleRange = tlm.documentRange.intersection(viewportRange)
    
    guard let visibleString = tcm.attributedString(in: visibleRange)?.string else { return .init() }
    
    let stringPreviewLength = 20
    let stringStart = visibleString.prefix(stringPreviewLength)
    let stringEnd = visibleString.suffix(stringPreviewLength)
    
    return EditorInfo.Scroll(
      summary: """
      Scroll offset: \(scrollOffset)
      Characters
      Visible: \(visibleString.count), Total: \(self.string.count)
      Visible preview:
      \(stringStart)...
      ...\(stringEnd)
      """
    )
  } // END scroll info
  
}

