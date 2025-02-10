//
//  EditorView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 8/2/2025.
//

import BaseHelpers
import MarkdownModels
import SwiftUI

public struct EditorView: View {
  @State private var windowWidth: CGFloat = .zero
  @Binding var text: String
  let configuration: MarkdownEditorConfiguration
  let height: (CGFloat) -> Void

  public init(
    text: Binding<String>,
    configuration: MarkdownEditorConfiguration = .init(),
    height: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.height = height
  }

  public var body: some View {

    ScrollView {
      MarkdownEditor(
        text: $text,
        width: windowWidth,
        configuration: configuration
      )
    }
    //    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onGeometryChange(for: CGSize.self) { proxy in
      return proxy.size
    } action: { newValue in
      windowWidth = newValue.width
      height(newValue.height)
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
