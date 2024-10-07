//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  
  public var frame: EditorInfo.Frame

  public init(
    frame: EditorInfo.Frame = .init()
  ) {
    self.frame = frame
  }

  public struct Frame: Sendable {
    public var width: CGFloat
    public var height: CGFloat
    
    public init(
      width: CGFloat = .zero,
      height: CGFloat = .zero
    ) {
      self.width = width
      self.height = height
    }
  }
}


protocol EditorInfoUpdatable {
  func updateIn(_ editorInfo: inout EditorInfo)
}

extension EditorInfo.Frame: EditorInfoUpdatable {
  func updateIn(_ editorInfo: inout EditorInfo) {
    editorInfo.frame = self
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
