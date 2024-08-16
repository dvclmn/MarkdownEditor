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

        await MainActor.run {
          self.onInfoUpdate(self.editorInfo)
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
