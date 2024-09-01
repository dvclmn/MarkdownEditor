//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI




extension MarkdownTextView {
  

  
  @objc func handleScrollViewDidScroll() {
    
    guard let scrollView = enclosingScrollView else { return }
    
    Task {
      await self.scrollDebouncer.processTask { [weak self] in
        
        guard let self = self else { return }
        
        await self.onAppearAndTextChange()
        
        
        
//        let scrollInfo = await self.textView.generateScrollInfo()
        //
//        Task { @MainActor in
//          await self.textView.infoHandler.update(scrollInfo)
//        }
        
      } // END process scroll
    } // END Task
    
    
    
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

extension MarkdownScrollView {
  
  public override func scrollWheel(with event: NSEvent) {
    super.scrollWheel(with: event)
    
    // Notify about scroll offset change
//    scrollOffsetDidChange?(contentView.bounds.origin)
    
    //    print("Scrolling happened: \(self.verticalScrollOffset)")
    
//    Task {
//      await self.textView.scrollDebouncer.processTask { [weak self] in
//        
//        guard let self = self else { return }
//        
//        await self.textView.onAppearAndTextChange()
//        
//        
//        
//        let scrollInfo = await self.textView.generateScrollInfo()
//        //
//        Task { @MainActor in
//          await self.textView.infoHandler.update(scrollInfo)
//        }
//        
//      } // END process scroll
//    } // END Task
//    
    
  }
  
}



extension MarkdownTextView {
  
  
  func generateScrollInfo() async -> EditorInfo.Scroll {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return .init() }
    
    let visibleRange = tlm.documentRange.intersection(viewportRange)
    
    guard let visibleString = tcm.attributedString(in: visibleRange)?.string else { return .init() }
    
    let stringPreviewLength = 10
    let stringStart = visibleString.prefix(stringPreviewLength)
    let stringEnd = visibleString.suffix(stringPreviewLength)
    
    return EditorInfo.Scroll(
      summary: """
      Characters
      Visible: \(visibleString.count), Total: \(self.string.count)
      Visible preview:
      \(stringStart)...
      ...\(stringEnd)
      """
    )
    
  } // END scroll info
  
}


