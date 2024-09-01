//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownScrollView {
  
//  public override func scrollWheel(with event: NSEvent) {
//    super.scrollWheel(with: event)
//    
//    // Notify about scroll offset change
//    scrollOffsetDidChange?(contentView.bounds.origin)
//    
//    //    print("Scrolling happened: \(self.verticalScrollOffset)")
//    
//    Task {
//      await self.textView.scrollDebouncer.processTask { [weak self] in
//        
//        guard let self = self else { return }
//        
////        await self.textView.onAppearAndTextChange()
//        
//        DispatchQueue.main.async {
//          self.textView.parseAndStyleMarkdownLite()
//        }
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
//    
//  }
//  
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


