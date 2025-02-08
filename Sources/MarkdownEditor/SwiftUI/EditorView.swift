//
//  EditorView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import SwiftUI
import BaseHelpers

public struct EditorView: View {
  @State private var windowWidth: CGFloat = .zero
  @Binding var text: String
  let config: EditorConfig
  
  public init(
    text: Binding<String>,
    config: EditorConfig = .init()
  ) {
    self._text = text
    self.config = config
  }
  
  public var body: some View {
    
    TempEditor(
      text: $text,
      width: windowWidth,
      config: config
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

