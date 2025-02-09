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
    
    let textStorage = MarkdownTextStorage()
    let layoutManager = NSLayoutManager()
    textStorage.addLayoutManager(layoutManager)
    
    let textContainer = NSTextContainer(size: .zero)
    layoutManager.addTextContainer(textContainer)

    let textView = MarkdownTextView(
      frame: .zero,
      textContainer: textContainer,
      configuration: configuration
    )

    if let textStorage = textView.textStorage,
      let textContainer = textView.textContainer
    {
      let oldLM = textView.layoutManager
      let codeLM = CodeBackgroundLayoutManager(configuration: configuration)
      textStorage.removeLayoutManager(oldLM!)
      textStorage.addLayoutManager(codeLM)
      codeLM.addTextContainer(textContainer)
    }

    textView.delegate = context.coordinator
    textView.string = text
    textView.setUpTextView(configuration)
    styleText(textView: textView)
    
    return textView
  }

  public func updateNSView(_ nsView: MarkdownTextView, context: Context) {

    let textView = nsView

    if textView.string != text {
      
      textView.string = text
      
//      // Begin editing.
//      textView.textStorage?.beginEditing()
//
//      // Replace the text.
//      textView.textStorage?.replaceCharacters(
//        in: NSRange(location: 0, length: textView.textStorage?.length ?? 0), with: text)
//
//      // End editing.
//      textView.textStorage?.endEditing()

      // Apply syntax highlighting.

//      DispatchQueue.main.async {
        styleText(textView: textView)
//      }

      // Update container width.
      textView.updateContainerWidth(width: width)
    }


  }
}
