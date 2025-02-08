//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
import MarkdownModels

//public typealias InfoUpdate = @Sendable (EditorInfo) -> Void

@MainActor
public struct MarkdownEditor: NSViewControllerRepresentable {
  
  public typealias NSViewControllerType = MarkdownViewController
  
  @Binding var text: String
  var width: CGFloat
  var configuration: MarkdownEditorConfiguration
//  var info: InfoUpdate
  
  public init(
    text: Binding<String>,
    width: CGFloat,
    configuration: MarkdownEditorConfiguration = .init()
//    info: @escaping InfoUpdate = { _ in }
  ) {
    self._text = text
    self.width = width
    self.configuration = configuration
//    self.info = info
  }
  
  public func makeNSViewController(context: Context) -> MarkdownViewController {
    
    let viewController = MarkdownViewController(
      configuration: self.configuration
    )
    viewController.loadView()
    
    let textView = viewController.textView
    
    if let textStorage = textView.textStorage,
       let textContainer = textView.textContainer {
      
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
    
    
    return viewController
  }
  
  public func updateNSViewController(_ nsView: MarkdownViewController, context: Context) {
    
    let textView = nsView.textView
    
    if textView.string != text {
      // Begin editing.
      textView.textStorage?.beginEditing()
      
      // Replace the text.
      textView.textStorage?.replaceCharacters(in: NSRange(location: 0, length: textView.textStorage?.length ?? 0), with: text)
      
      // End editing.
      textView.textStorage?.endEditing()
      
      // Apply syntax highlighting.
      styleText(textView: textView)
    }
    
    // Update container width.
    textView.updateContainerWidth(width: width)

  }
  
    public func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }
}



