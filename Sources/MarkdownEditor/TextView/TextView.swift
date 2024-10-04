//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import BaseHelpers


public class MarkdownTextView: NSTextView {
  
  var scrollView: NSScrollView?
  
  var elements: [Markdown.Element] = []
  var parsingTask: Task<Void, Never>?
  
  var maxWidth: CGFloat = .infinity
  
  var parseDebouncer = Debouncer(interval: 0.05)
  
  let infoHandler = EditorInfoHandler()
  
  var configuration: MarkdownEditorConfiguration
  
  var editorInfo = EditorInfo()
  
  var currentParagraph = ParagraphInfo()

  private var viewportLayoutController: NSTextViewportLayoutController?
  var viewportDelegate: MarkdownViewportDelegate?
  
  var lastSelectedText: String = ""
  
  public var onInfoUpdate: MarkdownEditor.InfoUpdate = { _ in }
  
  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    
    configuration: MarkdownEditorConfiguration
    
  ) {
    self.configuration = configuration
    
    /// First, we provide TextKit with a frame
    ///
    let container = NSTextContainer()
    
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
    textLayoutManager.textContainer = container
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    
    super.init(frame: frameRect, textContainer: container)
    
    self.textViewSetup()
    
    self.infoHandler.onInfoUpdate = { [weak self] info in
      self?.onInfoUpdate(info)
    }
    
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override var layoutManager: NSLayoutManager? {
    assertionFailure("TextKit 1 is not supported")
    return nil
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
//  public override var intrinsicContentSize: NSSize {
//    
//    guard let tlm = textLayoutManager else { return super.intrinsicContentSize }
//    
//    tlm.ensureLayout(for: tlm.documentRange)
//    
////    tlm.textContainer?.layoutManager?.usedRect(for: self.textContainer)
//    
//
//
////    layoutManager.ensureLayout(for: self.textContainer!)
//    return layoutManager.usedRect(for: self.textContainer!).size
//  }
  
  
//  public override func setFrameSize(_ newSize: NSSize) {
//    let width = min(newSize.width, maxWidth)
//    super.setFrameSize(NSSize(width: width, height: newSize.height))
//    self.textContainer?.size = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)
//    self.invalidateIntrinsicContentSize()
//  }
  
//  var scrollView: NSScrollView {
//    
////    guard configuration.isScrollable else {
////      print("Text view isn't scrollable, returning nil")
////      return nil
////    }
//    
//    guard let result = self.enclosingScrollView,
//          result.documentView == self
//    else {
//      fatalError("The text view needs a scroll view.")
//    }
//    return result
//  }
  
//  public override func setFrameSize(_ newSize: NSSize) {
//    super.setFrameSize(newSize)
//    textContainer?.containerSize = NSSize(width: newSize.width, height: CGFloat.greatestFiniteMagnitude)
////    if !configuration.isScrollable {
////    }
//  }

  
  
}

extension MarkdownTextView {
  
  
  func setupViewportLayoutController() {
    guard let textLayoutManager = self.textLayoutManager else { return }
    
    self.viewportDelegate = MarkdownViewportDelegate()
    self.viewportDelegate?.textView = self
    
    self.viewportLayoutController = NSTextViewportLayoutController(textLayoutManager: textLayoutManager)
    self.viewportLayoutController?.delegate = viewportDelegate
  }
  
  
  public override func draw(_ rect: NSRect) {
    super.draw(rect)
    
    if configuration.isShowingFrames {
      
      let colour: NSColor = configuration.isEditable ? .red : .purple
      
      let border:NSBezierPath = NSBezierPath(rect: bounds)
      let borderColor = colour.withAlphaComponent(0.08)
      borderColor.set()
      border.lineWidth = 1.0
      border.fill()
    }
  }
}
