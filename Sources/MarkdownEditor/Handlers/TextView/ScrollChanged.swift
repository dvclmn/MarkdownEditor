//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
  func didChangeScroll() {
    Task {
      await scrollHandler.processScroll { [weak self] in
        guard let self = self else { return }
        if let info = await self.calculateScrollInfo() {
          await MainActor.run {
            self.onScrollChange(info)
          }
        }
      }
    }
  }
  
  private func calculateScrollInfo() async -> EditorInfo.Scroll? {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let viewportRange = tlm.textViewportLayoutController.viewportRange
    else { return nil }
    
    let visibleRange = tlm.documentRange.intersection(viewportRange)
    
    let visibleString = tcm.attributedString(in: visibleRange)
    
    
    
    return EditorInfo.Scroll(
      summary: """
      Scroll offset: \(scrollOffset)
      Characters
      Visible: \(visibleString?.string.count ?? 0), Total: \(self.string.count)
      
      """
    )
  }

  
}

actor ScrollHandler {
  private var debounceTask: Task<Void, Never>?
  
  func processScroll(action: @escaping @Sendable () async -> Void) {
    debounceTask?.cancel()
    debounceTask = Task { [action] in
      do {
        try await Task.sleep(for: .seconds(0.2))
        if !Task.isCancelled {
          await action()
        }
      } catch {
        // Handle cancellation or other errors
      }
    }
  }
}
