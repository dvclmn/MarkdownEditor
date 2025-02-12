//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import BaseHelpers
import MarkdownModels
import SwiftUI

@MainActor
public struct MarkdownEditor: NSViewRepresentable {

  @Binding var text: String
  var configuration: EditorConfiguration
  var height: (CGFloat) -> Void

  public init(
    text: Binding<String>,
    configuration: EditorConfiguration = .init(),
    height: @escaping (CGFloat) -> Void = { _ in }
  ) {
    self._text = text
    self.configuration = configuration
    self.height = height
  }

  public func makeNSView(context: Context) -> MarkdownScrollView {
    let view = MarkdownScrollView(
      frame: .zero,
      configuration: configuration
    )
    view.textView.delegate = context.coordinator
    view.textView.setUpTextView(configuration)

    view.textView.heightChanged = { newHeight in
      DispatchQueue.main.async {
        self.height(newHeight)
      }
    }

    return view
  }

  public func updateNSView(_ nsView: MarkdownScrollView, context: Context) {

    let textView = nsView.textView

    if textView.string != text {
      textView.string = text
      textView.processText(text)
//      textView.invalidateIntrinsicContentSize()
    }
  }
}
