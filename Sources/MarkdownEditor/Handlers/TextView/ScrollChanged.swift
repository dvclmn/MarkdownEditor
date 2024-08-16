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
        
        let textInfo = await self.calculateTextInfo()
        let scrollInfo = await self.calculateScrollInfo()
        
        await MainActor.run {
          self.onTextChange(textInfo)
          self.onScrollChange(scrollInfo)
        }

      } // END process scroll
    } // END Task
  } // END did change scroll
  
  private func calculateScrollInfo() async -> EditorInfo.Scroll {
    
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
