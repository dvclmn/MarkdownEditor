//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownScrollView {
  
  public override func scrollWheel(with event: NSEvent) {
    super.scrollWheel(with: event)
    
    // Notify about scroll offset change
    scrollOffsetDidChange?(contentView.bounds.origin)
    
    print("Scrolling happened: \(self.verticalScrollOffset)")
  }
  
  
}

extension MarkdownTextView {
  
//  func generateScrollInfo() async -> EditorInfo.Scroll {
//    
//    guard let tlm = self.textLayoutManager,
//          let tcm = tlm.textContentManager,
//          let viewportRange = tlm.textViewportLayoutController.viewportRange
//    else { return .init() }
//    
//    let visibleRange = tlm.documentRange.intersection(viewportRange)
//    
//    guard let visibleString = tcm.attributedString(in: visibleRange)?.string else { return .init() }
//    
//    let stringPreviewLength = 20
//    let stringStart = visibleString.prefix(stringPreviewLength)
//    let stringEnd = visibleString.suffix(stringPreviewLength)
//    
//    return EditorInfo.Scroll(
//      summary: """
//      Characters
//      Visible: \(visibleString.count), Total: \(self.string.count)
//      Visible preview:
//      \(stringStart)...
//      ...\(stringEnd)
//      """
//    )
//    
//  } // END scroll info
  
}


