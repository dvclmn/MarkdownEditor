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
//  var width: CGFloat
  var configuration: EditorConfiguration

  public init(
    text: Binding<String>,
//    width: CGFloat,
    configuration: EditorConfiguration = .init()
  ) {
    self._text = text
//    self.width = width
    self.configuration = configuration
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
    
//    if textView.width != width {
//      textView.width = width
//      textView.updateContainerWidth(width: width)
//    }
  }
}
