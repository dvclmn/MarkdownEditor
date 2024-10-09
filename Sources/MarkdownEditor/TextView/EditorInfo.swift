//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  public var size: CGSize
  public var metrics: Metrics
  
  public init(
    size: CGSize = .zero,
    metrics: Metrics = .init()
  ) {
    self.size = size
    self.metrics = metrics
  }
  
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

final class EditorInfoHandler {
  private var editorInfo = EditorInfo()
  var onInfoUpdate: InfoUpdate?
  
  func updateSize(_ size: CGSize) {
    editorInfo.size = size
    notifyUpdate()
  }
  
  func updateMetrics(_ metrics: EditorInfo.Metrics) {
    editorInfo.metrics = metrics
    notifyUpdate()
  }
  
  func updateLineCount(to count: Int) {
    editorInfo.metrics.lineCount = count
    notifyUpdate()
  }
  
  func updateCharacterCount(to count: Int) {
    editorInfo.metrics.characterCount = count
    notifyUpdate()
  }
  
  private func notifyUpdate() {
    onInfoUpdate?(editorInfo)
//    Task { @MainActor in
//    }
  }
}
//
//extension MarkdownTextView {
//  func setupInfoHandler() {
//    infoHandler.onInfoUpdate = { [weak self] info in
//      self?.onInfoUpdate(info)
//    }
//  }
//}

extension MarkdownTextView {
  func setupInfoHandler() {
    Task {
      self.infoHandler.onInfoUpdate = { [weak self] info in
        self?.onInfoUpdate(info)
      }
    }
  }
}
