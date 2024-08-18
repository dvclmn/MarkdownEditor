//
//  Timer.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI


extension MarkdownTextView {
  
  func measureBackgroundTaskTime(_ task: @escaping () async -> Void) async -> Double {
    let startTime = ProcessInfo.processInfo.systemUptime
    
    await Task.detached(priority: .background) {
      await task()
    }.value
    
    let endTime = ProcessInfo.processInfo.systemUptime
    
    let timeInterval = endTime - startTime
    
    return timeInterval * 1000 // Convert to milliseconds
  }
}
