//
//  EditorView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import BaseHelpers
import SwiftUI

public struct EditorView: View {
  
  @State private var store: EditorHandler = .init()
  @State private var debounceTimer: Timer?
  
  @Binding var text: String
  let configuration: EditorConfiguration
  let editorModeHeight: (CGFloat) -> Void

  public init(
    text: Binding<String>,
    options: [EditorConfiguration.Option],
    editorModeHeight: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = EditorConfiguration(options: options)
    self.editorModeHeight = editorModeHeight
  }
  
  public init(
    text: Binding<String>,
    configuration: EditorConfiguration = .init(),
    editorModeHeight: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.editorModeHeight = editorModeHeight
  }

  public var body: some View {
    
    Text(text.count.string)
    
    @Bindable var store = store

      MarkdownEditor(
        text: $text,
        configuration: configuration
      ) { height in
        if configuration.isEditable {
          self.editorModeHeight(height)
        } else {
          store.displayModeHeight = height
        }
      }
    /// We only want to set a SwiftUI frame height when the
    /// text view is in `displayMode` (non-editable)
      .frame(height: configuration.isEditable ? nil : store.displayModeHeight)
      .border(Color.green.opacity(0.3))
  }
}
#if DEBUG
  @available(macOS 15, iOS 18, *)
  #Preview() {
    @Previewable @State var text: String = TestStrings.Markdown.basicMarkdown
    EditorView(text: $text)
  }
#endif
