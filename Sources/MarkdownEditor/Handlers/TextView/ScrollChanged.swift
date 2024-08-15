//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  
//  func didChangeScroll() {
//    
//    
//    
//    Task {
//      await scrollHandler.updateScrollOffset(scrollOffset) { [weak self] scrollInfo in
//        guard let self = self else { return }
//        DispatchQueue.main.async {
//          
//          if let info = self.calculateScrollInfo() {
//            self.onScrollChange(info)
//          }
//        }
//      }
//    }
//  }
  
  func didChangeScroll() {
    Task {
      await scrollHandler.processScroll {
        if let info = self.calculateScrollInfo() {
          self.onScrollChange(info)
        }
      }
    }
  }
  
  func calculateScrollInfo() -> EditorInfo.Scroll? {
    return EditorInfo.Scroll(
      summary: "Hello!"
    )
  }
  
}

actor ScrollHandler {
  
  private(set) var lastScrollOffset: CGFloat = .zero
  //  private var onScrollChange: ((EditorInfo.Scroll) -> Void)?
  private var debounceTask: Task<Void, Never>?
  
  var action: () -> Void
  
  
  
  //  func updateScrollOffset(_ newOffset: CGFloat, onScrollChange: @escaping (EditorInfo.Scroll) -> Void) {
  //    if newOffset != lastScrollOffset {
  //      lastScrollOffset = newOffset
  //      self.onScrollChange = onScrollChange
  //      debounceScrollChange()
  //    }
  //  }
  
  private func debounceScrollChange() {
    debounceTask?.cancel()
    debounceTask = Task {
      do {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        if !Task.isCancelled {
          action()
        }
      } catch {
        // Handle cancellation or other errors
      }
    }
  }
  
  //  private func processScrollChange() {
  //    let scrollInfo = EditorInfo.Scroll(summary: "Scrolled to offset: \(lastScrollOffset)")
  //    onScrollChange?(scrollInfo)
  //  }
}
