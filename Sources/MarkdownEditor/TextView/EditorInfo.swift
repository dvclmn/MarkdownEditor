//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  
  public var size: CGSize
  public var metrics: EditorInfo.Metrics
  
  public init(
    size: CGSize = .zero,
    metrics: EditorInfo.Metrics = .init()
  ) {
    self.size = size
    self.metrics = metrics
  }
  
}

extension EditorInfo {
  
  public struct Metrics: Sendable {
    public var lineCount: Int
    public var characterCount: Int
    
    public init(
      lineCount: Int = 0,
      characterCount: Int = 0
    ) {
      self.lineCount = lineCount
      self.characterCount = characterCount
    }
  }
}


extension EditorInfo {
  
  mutating func updateSize(_ size: CGSize) {
    self.size = size
  }
  
  mutating func updateMetrics(_ metrics: Metrics) {
    self.metrics = metrics
  }
}

enum MetricType {
  case lineCount
  case characterCount
}


extension EditorInfoHandler {
  func updateLineCount(to count: Int) {
    var currentMetrics = editorInfo.metrics
    currentMetrics.lineCount = count
    updateMetrics(currentMetrics)
  }
  
  func updateCharacterCount(to count: Int) {
    var currentMetrics = editorInfo.metrics
    currentMetrics.characterCount = count
    updateMetrics(currentMetrics)
  }
  
}



actor EditorInfoHandler {
  
  /// This just holds on to the instance of the `EditorInfo` struct
  private var editorInfo = EditorInfo()
  
  var onInfoUpdate: InfoUpdate?
  
  /// Updates the size of the editor and notifies listeners.
  func updateSize(_ size: CGSize) {
    editorInfo.size = size
    notifyUpdate()
  }
  
  /// Updates the info string of the editor and notifies listeners.
  func updateInfo(_ info: String) {
    editorInfo.info = info
    notifyUpdate()
  }
  
  /// Notifies listeners about the updated `EditorInfo`.
  private func notifyUpdate() {
    onInfoUpdate?(editorInfo)
  }
}

extension MarkdownTextView {
  func setupInfoHandler() {
    infoHandler.onInfoUpdate = { [weak self] info in
      self?.onInfoUpdate(info)
    }
  }
}
