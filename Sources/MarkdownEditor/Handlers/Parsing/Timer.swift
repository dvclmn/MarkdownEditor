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
      await self.profile("Parse markdown") {
        await task()
      }
    }.value
    
    let endTime = ProcessInfo.processInfo.systemUptime
    
    let timeInterval = endTime - startTime
    
    return timeInterval * 1000 // Convert to milliseconds
  }
  
  
  func profile(_ name: String, operation: @escaping () async -> Void) async {
    let start = Date()
    await operation()
    let duration = Date().timeIntervalSince(start)
    
    await profiler.addOrUpdateProfile(ProfileInfo(name: name, duration: duration))
  }
  
}


