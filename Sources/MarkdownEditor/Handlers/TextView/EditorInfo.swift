//
//  EditorInfo.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 14/8/2024.
//

import SwiftUI


public struct EditorInfo: Sendable {
  
  public var frame: EditorInfo.Frame
//  public var text: EditorInfo.Text
//  public var selection: EditorInfo.Selection
//  public var scroll: EditorInfo.Scroll
  
  public init(
    frame: EditorInfo.Frame = .init()
//    text: EditorInfo.Text = .init(),
//    selection: Selection = EditorInfo.Selection(),
//    scroll: Scroll = EditorInfo.Scroll()
  ) {
    self.frame = frame
//    self.text = text
//    self.selection = selection
//    self.scroll = scroll
  }
  
  public struct Text: Sendable {
    var scratchPad: String = ""
    
    /// Previous useful metrics
    ///
//    Insets: \(self.textContainer?.lineFragmentPadding.description ?? "")
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
    var summary: String = "Summary here"
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

//extension EditorInfo.Text: EditorInfoUpdatable {
//  func updateIn(_ editorInfo: inout EditorInfo) {
//    editorInfo.text = self
//  }
//}
//
//extension EditorInfo.Selection: EditorInfoUpdatable {
//  func updateIn(_ editorInfo: inout EditorInfo) {
//    editorInfo.selection = self
//  }
//}
//
//extension EditorInfo.Scroll: EditorInfoUpdatable {
//  func updateIn(_ editorInfo: inout EditorInfo) {
//    editorInfo.scroll = self
//  }
//}

@MainActor
class EditorInfoHandler {
  private var editorInfo = EditorInfo()
  var onInfoUpdate: ((EditorInfo) -> Void)?
  
  func update<T: EditorInfoUpdatable>(_ updatable: T) async {
    updatable.updateIn(&editorInfo)
    onInfoUpdate?(editorInfo)
  }
}
