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
  var width: CGFloat
  var configuration: EditorConfiguration

  public init(
    text: Binding<String>,
    width: CGFloat,
    configuration: EditorConfiguration = .init()
  ) {
    self._text = text
    self.width = width
    self.configuration = configuration
  }

  public func makeNSView(context: Context) -> MarkdownTextView {

    let textStorage = MarkdownTextStorage(configuration: configuration)
    let layoutManager = MarkdownLayoutManager(configuration: configuration)
    textStorage.addLayoutManager(layoutManager)

    let textContainer = NSTextContainer(size: .zero)
    layoutManager.addTextContainer(textContainer)

    let textView = MarkdownTextView(
      frame: .zero,
      textContainer: textContainer,
      configuration: configuration,
      width: width
    )
    
    textView.delegate = context.coordinator
    textView.string = text
    textView.setUpTextView(configuration)

    return textView
  }

  public func updateNSView(_ nsView: MarkdownTextView, context: Context) {

    let textView = nsView

    if textView.string != text {
      textView.string = text
    }
    
    if textView.width != width {
      print("text view width: \(textView.width), SwiftUI width: \(width)")
      textView.width = width
    }
    
    textView.updateContainerWidth(width: width)
  }
}
