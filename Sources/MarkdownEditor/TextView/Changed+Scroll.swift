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
    
//    Task {
//      await self.scrollDebouncer.processTask { [weak self] in
//        
//        guard let self = self else { return }
//        
//       await scrollInfo(scrollView: scrollView)
//        
////        await self.styleElements(trigger: .scroll)
//        
//        
////        let scrollInfo = await self.textView.generateScrollInfo()
//        //
////        Task { @MainActor in
////          await self.textView.infoHandler.update(scrollInfo)
////        }
//        
//      } // END process scroll
//    } // END Task
    
  } // END handle scroll view
  
  func scrollInfo(scrollView: NSScrollView) {
    let scrollInfo: String = """
        
        """
    
    print(scrollInfo)
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
    
    
    return EditorInfo.Scroll(
      summary: """
      Characters
      """
    )
    
  } // END scroll info
  
}


