//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers


public class MarkdownTextView: NSTextView {
  
  var lastFrame: NSRect = .zero
  var isUpdatingFrame = false
  
  var textIsEditing: Bool = false
  
  var scrollView: NSScrollView?
  
  var elements: Set<Markdown.Element> = []
  
  //  var elements: [Markdown.Element] = []
  var parsingTask: Task<Void, Never>?
  
  var maxWidth: CGFloat = .infinity
  
  var parseDebouncer = Debouncer(interval: 0.05)
  
  var adjustWidthDebouncer = Debouncer(interval: 0.2)
  
  let infoHandler = EditorInfoHandler()
  
  var configuration: MarkdownEditorConfiguration
  
//  var editorInfo = EditorInfo()
  
//  var currentParagraph = ParagraphInfo()
  
  //  var viewportLayoutController: NSTextViewportLayoutController?
  //  var viewportDelegate: MarkdownViewportDelegate?
  
  var lastSelectedText: String = ""
  
  public var onInfoUpdate: MarkdownEditor.InfoUpdate = { _ in }
  
  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    
    configuration: MarkdownEditorConfiguration
    
  ) {
    
    self.configuration = configuration
    
    if configuration.isTextKit2 {
      
      /// First, we provide TextKit with a frame
      ///
      let nsTextContainer = NSTextContainer()
      
      /// Then we need some content to display, which is handled by `NSTextContentManager`,
      /// which uses `NSTextContentStorage` by default
      ///
      let textContentStorage = NSTextContentStorage()
      
      /// This content is then laid out by `NSTextLayoutManager`
      ///
      let textLayoutManager = NSTextLayoutManager()
      
      /// Finally we connect these parts together.
      ///
      /// > Important: Access to the text container is through the `textLayoutManager`.
      /// > There is still a `textContainer` property directly on `NSTextView`, but as
      /// > I understand it, that isn't the one we use.
      ///
      textLayoutManager.textContainer = nsTextContainer
      textContentStorage.addTextLayoutManager(textLayoutManager)
      textContentStorage.primaryTextLayoutManager = textLayoutManager
      
      super.init(frame: frameRect, textContainer: nsTextContainer)
      
    } else {
      
      super.init(frame: frameRect, textContainer: container)
      
    }
    
    self.textViewSetup()
    
    self.infoHandler.onInfoUpdate = { [weak self] info in
      self?.onInfoUpdate(info)
    }
    
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

//  deinit {
//    NotificationCenter.default.removeObserver(self)
//  }
  
  var horizontalInsets: CGFloat {
    
    let width = self.frame.width
    let maxWidth: CGFloat = configuration.maxReadingWidth
    
    if width > maxWidth + (configuration.insets * 2) {
      return (width - maxWidth) / 2
    } else {
      return configuration.insets
    }
    
  }
  
  
  
  public override var frame: NSRect {
    didSet {
      print("The text view's frame changed. Width: `\(frame.width)`, Height: `\(frame.height)`")
      //        onFrameChange()
    }
  } // END frame override
}

extension MarkdownTextView {
  
  
}


