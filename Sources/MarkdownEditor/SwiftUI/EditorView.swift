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
  
  @State private var store: EditorHandler = .init()
  @State private var debounceTimer: Timer?
  
  @Binding var text: String
  let configuration: EditorConfiguration
  let height: (CGFloat) -> Void

  public init(
    text: Binding<String>,
    options: [EditorConfiguration.Option],
    height: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = EditorConfiguration(options: options)
    self.height = height
  }
  
  public init(
    text: Binding<String>,
    configuration: EditorConfiguration = .init(),
    height: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.height = height
  }

  public var body: some View {
    
    @Bindable var store = store

    ScrollView {
      MarkdownEditor(
        text: $text,
        width: store.windowWidth,
        configuration: configuration
      )
    }

    .onGeometryChange(for: CGSize.self) { proxy in
      return proxy.size
    } action: { newValue in
      
      debounceTimer?.invalidate()
      debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
        store.windowWidth = newValue.width
        height(newValue.height)
      }
      
      
//      store.windowWidth = newValue.width
//      height(newValue.height)
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
