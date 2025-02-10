//
//  EditorHandler.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/2/2025.
//

import SwiftUI

@Observable
final class EditorHandler {
  
  /// Obtained from AppKit, for *non-editable* text views
  var editorHeight: CGFloat = .zero
//  var windowWidth: CGFloat = .zero
}

struct FontSizeHandler {
  private let defaultSize: CGFloat = 14
  private let minSize: CGFloat = 8.0
  private let maxSize: CGFloat = 72.0
  private let stepSize: CGFloat = 1.0
}
