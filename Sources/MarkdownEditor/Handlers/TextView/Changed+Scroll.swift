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
