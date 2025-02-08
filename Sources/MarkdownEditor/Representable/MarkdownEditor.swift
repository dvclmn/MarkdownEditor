//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import BaseHelpers
import MarkdownModels
import SwiftUI

//public typealias InfoUpdate = @Sendable (EditorInfo) -> Void

@MainActor
public struct MarkdownEditor: NSViewRepresentable {

  @Binding var text: String
  var width: CGFloat
  var configuration: MarkdownEditorConfiguration

  public init(
    text: Binding<String>,
    width: CGFloat,
    configuration: MarkdownEditorConfiguration = .init()
  ) {
    self._text = text
    self.width = width
    self.configuration = configuration
  }

  public func makeNSView(context: Context) -> MarkdownTextView {

    let textView = MarkdownTextView()

    if let textStorage = textView.textStorage,
      let textContainer = textView.textContainer
    {

      /// Save a reference to the original layout manager (if any).
      let oldLM = textView.layoutManager

      /// Create an instance of our custom layout manager.
      let codeLM = InlineCodeLayoutManager()

      /// Remove the old layout manager and add our custom one.
      textStorage.removeLayoutManager(oldLM!)
      textStorage.addLayoutManager(codeLM)
      codeLM.addTextContainer(textContainer)
    }

    textView.delegate = context.coordinator
    textView.string = text
    textView.setUpTextView(configuration)
    styleText(textView: textView)
    /// The below isn't neccesary unless I feel there's a need for a weak reference
    /// to the `textView` held by the coordinator/
    //    context.coordinator.textView = textView

    //    textView.textStorage?.delegate = context.coordinator
    //    textView.textLayoutManager?.delegate = context.coordinator


    return textView
  }

  public func updateNSView(_ nsView: MarkdownTextView, context: Context) {

    let textView = nsView

    if textView.string != text {
      // Begin editing.
      textView.textStorage?.beginEditing()

      // Replace the text.
      textView.textStorage?.replaceCharacters(
        in: NSRange(location: 0, length: textView.textStorage?.length ?? 0), with: text)

      // End editing.
      textView.textStorage?.endEditing()

      // Apply syntax highlighting.
      styleText(textView: textView)
    }

    // Update container width.
    textView.updateContainerWidth(width: width)

  }
}
