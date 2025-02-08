//
//  EditorView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import SwiftUI
import BaseHelpers
import MarkdownModels

public struct EditorView: View {
  @State private var windowWidth: CGFloat = .zero
  @Binding var text: String
  let configuration: MarkdownEditorConfiguration
  
  public init(
    text: Binding<String>,
    configuration: MarkdownEditorConfiguration = .init()
  ) {
    self._text = text
    self.configuration = configuration
  }
  
  public var body: some View {
    
    MarkdownEditor(
      text: $text,
      width: windowWidth,
      configuration: configuration
    )
    .onGeometryChange(for: CGFloat.self) { proxy in
      return proxy.size.width
    } action: { newValue in
      windowWidth = newValue
    }
    
  }
}
#if DEBUG
@available(macOS 15, iOS 18, *)
#Preview() {
  @Previewable @State var text: String = TestStrings.Markdown.basicMarkdown
  EditorView(text: $text)
}
#endif

