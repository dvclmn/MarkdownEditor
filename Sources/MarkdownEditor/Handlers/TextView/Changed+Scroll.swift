//
//  ScrollChanged.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 15/8/2024.
//

import SwiftUI

extension MarkdownTextView {
  
//  func didChangeScroll() {
//    Task {
//      await scrollHandler.processTask { [weak self] in
//        
//        guard let self = self else { return }
//        
//        let info = await self.generateScrollInfo()
//        Task { @MainActor in
//          await self.infoHandler.update(info)
//        }
//        
//      } // END process scroll
//    } // END Task
//  } // END did change scroll
  
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



actor Debouncer {
  private var task: Task<Void, Never>?
  private let interval: Double
  
  init(interval: Double = 0.2) {
    self.interval = interval
  }
  
  func processTask(action: @escaping @Sendable () async -> Void) {
    task?.cancel()
    task = Task { [weak self, action] in
      guard let self = self else { return }
      do {
        try await Task.sleep(for: .seconds(self.interval))
        if !Task.isCancelled {
          await action()
        }
      } catch {
        // Handle cancellation or other errors
      }
    }
  }
}
