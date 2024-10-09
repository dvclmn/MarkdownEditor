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
  
  
  func updateMetrics<Property: MetricUpdatable>(_ property: inout Property, value: Property.ValueType) {
    var currentMetrics = editorInfo.metrics
    currentMetrics.update(&property, with: value)
    editorInfo.metrics = currentMetrics
    notifyUpdate()
  }
  
  private func notifyUpdate() {
    onInfoUpdate?(editorInfo)
  }
}

public protocol MetricUpdatable {
  associatedtype ValueType
  
  var name: String { get } // Name of the property for logging or updating
  mutating func update(with value: ValueType)
}

extension Int: MetricUpdatable {
  public var name: String { "Int" }
  
  public mutating func update(with value: Int) {
    self = value
  }
}

extension String: MetricUpdatable {
  public var name: String { "String" }
  
  public mutating func update(with value: String) {
    self = value
  }
}

// Extend Metrics to conform to the protocol
extension EditorInfo.Metrics {
  mutating func update<Property: MetricUpdatable>(
    _ property: inout Property,
    with value: Property.ValueType
  ) {
    property.update(with: value)
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
