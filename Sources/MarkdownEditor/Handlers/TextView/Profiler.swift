//
//  Profiler.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 18/8/2024.
//

import AppKit

actor Profiler {
  static let shared = Profiler()
  private init() {}
  
  private var profiles: [ProfileInfo] = []
  private var totalDuration: TimeInterval = 0
  
  func reset() {
    profiles.removeAll()
    totalDuration = 0
  }
  
  func addProfile(_ profile: ProfileInfo) {
    profiles.append(profile)
    totalDuration += profile.duration
  }
  
  func calculatePercentages() {
    for i in 0..<profiles.count {
      profiles[i].percentage = (profiles[i].duration / totalDuration) * 100
    }
  }
  
  func getSignificantProfiles(threshold: Double = 1.0) -> [ProfileInfo] {
    calculatePercentages()
    return profiles.filter { $0.percentage >= threshold }
      .sorted { $0.percentage > $1.percentage }
  }
  
  
}

struct ProfileInfo: Sendable {
  let name: String
  let duration: TimeInterval
  var percentage: Double = 0
}
