//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers
import Highlightr

public class MarkdownTextView: NSTextView {
  
  var configuration: MarkdownEditorConfiguration
  
  let tlm: NSTextLayoutManager
  let tcm: NSTextContentManager
  
  
  
  let highlightr: Highlightr
  
  var scrollView: NSScrollView?
  
  var isUpdatingFrame: Bool = false
  var isUpdatingText: Bool = false
  
  var lastSentHeight: CGFloat = 0
  var lastSelectedText: String = ""
  
  var elements: Set<Markdown.Element> = []
  var currentParagraph: ParagraphInfo = .zero
  
  var onWidthChange: ((CGFloat) -> Void)?
  
  
  /// Debouncers
  ///
  var frameDebouncer = Debouncer(interval: 0.3)
  var parsingDebouncer = Debouncer(interval: 0.1)
  var infoDebouncer = Debouncer(interval: 0.3)
  var paragraphDebouncer = Debouncer(interval: 0.3)
//  var stylingDebouncer = Debouncer(interval: 0.3)
  
  //  let infoHandler = EditorInfoHandler()
  
  let infoUpdater: EditorInfoUpdater
  
  public var onInfoUpdate: InfoUpdate = { _ in }
  
  
  
  
  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    scrollView: NSScrollView? = nil,
    configuration: MarkdownEditorConfiguration,
    highlightr: Highlightr
    
  ) {
    
    self.configuration = configuration
    self.highlightr = highlightr
    self.infoUpdater = EditorInfoUpdater()
    
    
    //    if configuration.isTextKit2 {
    
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
    
    self.tlm = textLayoutManager
    self.tcm = textLayoutManager.textContentManager!
    
    self.scrollView = scrollView
    
    super.init(frame: frameRect, textContainer: nsTextContainer)
    
    self.textViewSetup()
    
    self.setupInfoHandler()
    
    self.onWidthChange = { [weak self] newWidth in
      self?.handleWidthChange(newWidth: newWidth)
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
    
    print("Horizontal insets, Called @ \(Date.now.friendlyDateAndTime)")
    
    let width = self.frame.width
    let maxWidth: CGFloat = configuration.maxReadingWidth
    
    if width > maxWidth + (configuration.insets * 2) {
      return (width - maxWidth) / 2
    } else {
      return configuration.insets
    }
    
  }
  
  func handleWidthChange(newWidth: CGFloat) {
    
    // Perform your task here when the width changes
    print("Text view width changed to: \(newWidth)")
  }
  
}
