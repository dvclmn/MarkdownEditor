//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  
  var frame = EditorInfo.Frame()
  var text = EditorInfo.Text()
  var selection = EditorInfo.Selection()
  var scroll = EditorInfo.Scroll()
  
  
  public struct Text: Sendable {
    var characterCount: Int = 0
    var textElementCount: Int = 0
    var codeBlocks: Int = 0
    var documentRange: String = ""
    var viewportRange: String = ""
    var scratchPad: String = ""
  }
  
  public struct Selection: Sendable {
    var selection: String = ""
    //  var selectedRange: NSTextRange?
//    var selectedElement: [Markdown.Element] = []
    var location: Location? = nil
    var scratchPad: String = ""
    
    public struct Location: Sendable {
      var line: Int
      var column: Int
    }
  }
  
  public struct Scroll: Sendable {
    var summary: String = ""
  }
  
  public struct Frame: Sendable {
    var height: CGFloat = .zero
    var width: CGFloat = .zero
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

extension EditorInfo.Text: EditorInfoUpdatable {
  func updateIn(_ editorInfo: inout EditorInfo) {
    editorInfo.text = self
  }
}

extension EditorInfo.Selection: EditorInfoUpdatable {
  func updateIn(_ editorInfo: inout EditorInfo) {
    editorInfo.selection = self
  }
}

extension EditorInfo.Scroll: EditorInfoUpdatable {
  func updateIn(_ editorInfo: inout EditorInfo) {
    editorInfo.scroll = self
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
