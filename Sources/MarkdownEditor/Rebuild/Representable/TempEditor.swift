//
//  TempEditor.swift
//  Components
//
//  Created by Dave Coleman on 7/2/2025.
//

import SwiftUI


public struct TempEditor: NSViewRepresentable {
  
  @Binding var text: String
  var width: CGFloat
  var config: EditorConfig
  
  public init(
    text: Binding<String>,
    width: CGFloat,
    config: EditorConfig = .init()
  ) {
    self._text = text
    self.width = width
    self.config = config
  }
  
  public func makeNSView(context: Context) -> AutoSizingTextView {
    
    let textView = AutoSizingTextView()
    
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
    textView.setUpTextView(config)
    styleText(textView: textView)
    return textView
  }
  
  // MARK: - Update AppKit view when SwiftUI changes
  public func updateNSView(_ nsView: AutoSizingTextView, context: Context) {
    if nsView.string != text {
      // Begin editing.
      nsView.textStorage?.beginEditing()
      
      // Replace the text.
      nsView.textStorage?.replaceCharacters(in: NSRange(location: 0, length: nsView.textStorage?.length ?? 0), with: text)
      
      // End editing.
      nsView.textStorage?.endEditing()
      
      // Apply syntax highlighting.
      styleText(textView: nsView)
    }
    
    // Update container width.
    nsView.updateContainerWidth(width: width)
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
