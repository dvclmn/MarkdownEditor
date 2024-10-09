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
class EditorInfoHandler {
  private var editorInfo = EditorInfo()
  var onInfoUpdate: ((EditorInfo) -> Void)?
  
  func update<T: EditorInfoUpdatable>(_ updatable: T) async {
    updatable.updateIn(&editorInfo)
    onInfoUpdate?(editorInfo)
  }
}
