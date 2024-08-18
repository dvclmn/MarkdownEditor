//
//  Profiler.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 18/8/2024.
//

import AppKit


struct ProfileInfo: Sendable, Identifiable {
  let id: UUID
  let name: String
  var duration: TimeInterval
  var percentage: Double = 0
  
  init(name: String, duration: TimeInterval) {
    self.id = UUID()
    self.name = name
    self.duration = duration
  }

}

actor Profiler {
  static let shared = Profiler()
  private init() {}
  
  private var profiles: [ProfileInfo] = []
  private var totalDuration: TimeInterval = 0
  
  func reset() {
    profiles.removeAll()
    totalDuration = 0
  }
  
  func addOrUpdateProfile(_ profile: ProfileInfo) {
    if let index = profiles.firstIndex(where: { $0.name == profile.name }) {
      updateProfile(at: index, with: profile)
    } else {
      profiles.append(profile)
      totalDuration += profile.duration
    }
  }
  
  /// `inout` is being used here implicitly. When we modify `profiles[index]`, we're actually modifying the struct in place, which is equivalent to using `inout`.
  private func updateProfile(at index: Int, with newProfile: ProfileInfo) {
    totalDuration -= profiles[index].duration
    totalDuration += newProfile.duration
    profiles[index].duration = newProfile.duration
  }
  
  func calculatePercentages() {
    for index in profiles.indices {
      profiles[index].percentage = (profiles[index].duration / totalDuration) * 100
    }
  }
  
  func getSignificantProfiles(threshold: Double = 1.0) -> [ProfileInfo] {
    calculatePercentages()
    return profiles.filter { $0.percentage >= threshold }
      .sorted { $0.percentage > $1.percentage }
  }
  
  
}


extension MarkdownTextView {
  func generateProfilerReport() -> String? {
    
    let significantProfiles = profiler.getSignificantProfiles(threshold: 5.0)
    
    var profilesSummary: String = ""
    
    for profile in significantProfiles {
      
      profilesSummary += "\(profile.name): \(String(format: "%.3f", profile.duration)) seconds, \(String(format: "%.2f", profile.percentage))%)"
    }

    return profilesSummary
  }
}
