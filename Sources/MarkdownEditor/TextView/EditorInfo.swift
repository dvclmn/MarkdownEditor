//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  
  public var size: CGSize
  public var info: String

  public init(
    size: CGSize = .zero,
    info: String = "No info"
  ) {
    self.size = size
    self.info = info
  }

}


extension EditorInfo {
  
  mutating func updateSize(_ size: CGSize) {
    self.size = size
  }
  
  mutating func updateInfo(_ info: String) {
    self.info = info
  }
  
  
  
}


@MainActor
final class EditorInfoHandler: Sendable {
  
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
