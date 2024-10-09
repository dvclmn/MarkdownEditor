//
//  Change+Frame.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 7/10/2024.
//

import AppKit
import Glyph

extension MarkdownTextView {
  
  /// IMPORTANT:
  ///
  /// Trying to use a `layout` override, as a way to trigger parsing/styling/frame
  /// changes, is a BAD idea, and results in such messages as
  /// `attempted layout while textStorage is editing. It is not valid to cause the layoutManager to do layout while the textStorage is editing` etc
  
  
  public override var intrinsicContentSize: NSSize {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager
//          let container = self.textContainer
    else { return super.intrinsicContentSize }
    
//    guard let container = textContainer,
//          let layoutManager = layoutManager else {
//      return super.intrinsicContentSize
//    }
    
    
    let documentRange = tlm.documentRange
//    tlm.ensureLayout(for: documentRange)
    
    let documentNSRange = NSRange(documentRange, provider: tcm)
    
//    layoutManager.ensureLayout(for: container)
    
    guard let usedRect = self.boundingRect(for: documentNSRange)?.size else {
      return super.intrinsicContentSize
    }
    
//    let usedRect = layoutManager.usedRect(for: container).size
    
    return usedRect
    
  }
  

  
  func updatedEditorHeight() -> CGSize {
    
    invalidateIntrinsicContentSize()
    
    let newSize = intrinsicContentSize
    let extraHeightBuffer: CGFloat = configuration.isScrollable ? 0 : configuration.bottomSafeArea
    let minHeight: CGFloat = 80
    
    let adjustedHeight: CGFloat = newSize.height + extraHeightBuffer
    
    let finalHeight = max(adjustedHeight, minHeight)
    
    let result = CGSize(width: newSize.width, height: finalHeight)
    
    return result
    
  }
  
  
  
  func countLinesSimple() -> Int {
    
    let text = string
    
    let lines = text.split(separator: .newlineSequence)
    
    return lines.count
  }
  
  func countLinesTK2() -> Int {
    
    guard let textLayoutManager = textLayoutManager else {
      return 0
    }
    
    var lineCount = 0
    
    textLayoutManager.enumerateTextLayoutFragments(
      from: textLayoutManager.documentRange.location,
      options: [.ensuresLayout, .ensuresExtraLineFragment]
    ) { layoutFragment in
      lineCount += layoutFragment.textLineFragments.count
      return true
    }
    
    return lineCount
  }
  
}


