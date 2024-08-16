//
//  Timer.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 16/8/2024.
//

import SwiftUI


extension MarkdownProcessor {

  func measureBackgroundTaskTime(_ task: @escaping () async -> Void) async -> Double {
    let startTime = DispatchTime.now()
    
    await Task.detached(priority: .background) {
      await task()
    }.value
    
    let endTime = DispatchTime.now()
    
    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000 // Convert to milliseconds
    
    return timeInterval
  }


}
