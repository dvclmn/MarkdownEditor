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
    view.getTextView().delegate = context.coordinator
    view.getTextView().setUpTextView(configuration)

    return view
  }

  public func updateNSView(_ nsView: MarkdownScrollView, context: Context) {

    let textView = nsView.getTextView()

    if textView.string != text {
      textView.string = text
    }

    // In non-editable mode, let SwiftUI know the intrinsic height.
    if !configuration.isEditable {
      /// Force a layout update.
      nsView.layoutSubtreeIfNeeded()
      
      /// Retrieve the height from the text view’s intrinsic content size.
      let intrinsicHeight = textView.intrinsicContentSize.height
      
      /// Call the closure so SwiftUI can update its layout.
      DispatchQueue.main.async {
        height(intrinsicHeight)
      }
    }

  }
}
