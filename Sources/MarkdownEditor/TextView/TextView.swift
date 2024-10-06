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
  var adjustWidthDebouncer = Debouncer(interval: 0.2)
  
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
    print("Using TextKit 1")
//    assertionFailure("TextKit 1 is not supported")
    return nil
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private var oldWidth: CGFloat = 0
  
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
      onFrameChange()
    }
  } // END frame override
}

extension MarkdownTextView {
  
  func onFrameChange() {
    
//    print("Frame size change: \(frame)")
    
    if frame.width != oldWidth {
//      print("Frame width was different from old width (\(oldWidth)).")
      
      self.textContainer?.lineFragmentPadding = self.horizontalInsets
      
      Task {
        await adjustWidthDebouncer.processTask {
          
          Task { @MainActor in
            let heightUpdate = self.updateEditorHeight()
            await self.infoHandler.update(heightUpdate)
          }
          
        }
      }
      
      oldWidth = frame.width
    }
  }
  
  
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

