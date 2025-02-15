//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import BaseHelpers
import SwiftUI

@MainActor
public struct MarkdownEditor: NSViewControllerRepresentable {
  
  public typealias NSViewControllerType = MarkdownController

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

  public func makeNSViewController(context: Context) -> MarkdownController {
    let viewController = MarkdownController(configuration: configuration)
    viewController.textView.string = text
//    context.coordinator.setupTextViewBinding(viewController.textView)
    return viewController
  }
  
//  public func makeNSViewController(context: Context) -> MarkdownController {
//
//    let viewController = MarkdownController(configuration: configuration)
////    viewController.textView.delegate = context.coordinator
////    viewController.textView.setUpTextView(configuration)
//    viewController.textView.string = TestStrings.Markdown.basicMarkdown
////    viewController.textView.heightChanged = { newHeight in
////      DispatchQueue.main.async {
////        self.height(newHeight)
////      }
////    }
//
//    return viewController
//  }
//
  public func updateNSViewController(_ viewController: MarkdownController, context: Context) {

    let textView = viewController.textView
    if textView.string != text {
      textView.string = text
//      textView.invalidateIntrinsicContentSize()
    }
  }
}
