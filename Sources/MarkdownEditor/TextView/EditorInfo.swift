//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI
import BaseHelpers

// MARK: - EditorInfo

public struct EditorInfo: Sendable {
  public var size: CGSize
  public var lineCount: Int
  public var elementSummary: String
  public var typingAttributes: String
  
  public init(
    size: CGSize = .zero,
    lineCount: Int = 0,
    elementSummary: String = "No summary",
    typingAttributes: String = "No attributes"
    
  ) {
    self.size = size
    self.lineCount = lineCount
    self.elementSummary = elementSummary
    self.typingAttributes = typingAttributes
    
  }
}


public extension EditorInfo {
  
  var summary: String {
    let result: String = """
    Editor width: \(size.width.toDecimal(0)), height: \(size.height.toDecimal(0)) 
    Line count: \(lineCount)
    Elements: \(elementSummary)
    Typing attributes: \n\(typingAttributes)
    """
    
    return result
  }
}

@MainActor
final class EditorInfoUpdater: Sendable {
  private var editorInfo: EditorInfo
  private let debouncer: Debouncer
  public var onInfoUpdate: InfoUpdate?
  
  public init(
    initialInfo: EditorInfo = .init(),
    debounceInterval: Double = 0.3
  ) {
    self.editorInfo = initialInfo
    self.debouncer = Debouncer(interval: debounceInterval)
  }
  
  public func update<T: Sendable>(
    _ keyPath: WritableKeyPath<EditorInfo, T>,
    value: T
  ) async {
    
    Task { @MainActor in
      await debouncer.processTask { [weak self] in
        guard let self = self else { return }
        await self.performUpdate {
          $0[keyPath: keyPath] = value
        }
      }
    }
  }
  
  private func performUpdate(_ updateAction: (inout EditorInfo) -> Void) {
    var updatedInfo = self.editorInfo
    updateAction(&updatedInfo)
    self.editorInfo = updatedInfo
    self.onInfoUpdate?(self.editorInfo)
    
  }
  
  public func getCurrentInfo() -> EditorInfo {
    return editorInfo
  }
}



//
//
//final class EditorInfoHandler: Sendable {
//  private var editorInfo = EditorInfo()
//  var onInfoUpdate: InfoUpdate?
//
//  // Method to update size immutably
//  func updateSize(_ size: CGSize) {
//    editorInfo = EditorInfo(size: size, metrics: editorInfo.metrics)
//    notifyUpdate()
//  }
//
//  func updateMetric<T>(keyPath: WritableKeyPath<EditorInfo.Metrics, T>, value: T) {
//    let updatedMetrics = editorInfo.metrics.updating(keyPath: keyPath, value: value)
//    editorInfo = EditorInfo(size: editorInfo.size, metrics: updatedMetrics)
//    notifyUpdate()
//  }
//
//  private func notifyUpdate() {
//    onInfoUpdate?(editorInfo)
//  }
//
//}
//
//
//extension EditorInfo.Metrics {
//
//  public func updating<T>(
//    keyPath: WritableKeyPath<EditorInfo.Metrics, T>,
//    value: T
//  ) -> EditorInfo.Metrics {
//    var updatedMetrics = self
//    updatedMetrics[keyPath: keyPath] = value
//    return updatedMetrics
//  }
//}
//



extension MarkdownTextView {
  
  func setupInfoHandler() {
    
    Task {
      self.infoUpdater.onInfoUpdate = { [weak self] updatedInfo in
        self?.onInfoUpdate(updatedInfo)
      }
    }
    
    
    //    Task {
    //      self.infoHandler.onInfoUpdate = { [weak self] info in
    //        self?.onInfoUpdate(info)
    //      }
    //    }
  }
  
  
}
