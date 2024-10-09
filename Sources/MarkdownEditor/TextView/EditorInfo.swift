//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI

// MARK: - EditorInfo
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
}

// MARK: - EditorInfo.Metrics
public extension EditorInfo {
  
  struct Metrics: Sendable {
    public var lineCount: Int
    public var elementSummary: String
    public var typingAttributes: String

    
    public init(
      lineCount: Int = 0,
      elementSummary: String = "No summary",
      typingAttributes: String = "No attributes"

    ) {
      self.lineCount = lineCount
      self.elementSummary = elementSummary
      self.typingAttributes = typingAttributes

    }
  }
}

public extension EditorInfo.Metrics {
  
  var summary: String {
    let result: String = """
    Line count: \(lineCount)
    Elements: \(elementSummary)
    Typing attributes: \n\(typingAttributes)
    """
    
    return result
  }
}


final class EditorInfoHandler: Sendable {
  private var editorInfo = EditorInfo()
  var onInfoUpdate: InfoUpdate?
  
  // Method to update size immutably
  func updateSize(_ size: CGSize) {
    editorInfo = EditorInfo(size: size, metrics: editorInfo.metrics)
    notifyUpdate()
  }
  
  func updateMetric<T>(keyPath: WritableKeyPath<EditorInfo.Metrics, T>, value: T) {
    let updatedMetrics = editorInfo.metrics.updating(keyPath: keyPath, value: value)
    editorInfo = EditorInfo(size: editorInfo.size, metrics: updatedMetrics)
    notifyUpdate()
  }
  
  private func notifyUpdate() {
    onInfoUpdate?(editorInfo)
  }
  
}


extension EditorInfo.Metrics {
  
  public func updating<T>(
    keyPath: WritableKeyPath<EditorInfo.Metrics, T>,
    value: T
  ) -> EditorInfo.Metrics {
    var updatedMetrics = self
    updatedMetrics[keyPath: keyPath] = value
    return updatedMetrics
  }
}



extension MarkdownTextView {
  
  func setupInfoHandler() {
    Task {
      self.infoHandler.onInfoUpdate = { [weak self] info in
        self?.onInfoUpdate(info)
      }
    }
  }
  
}
