//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
//import STTextKitPlus

class LayoutManagerDelegate:  NSTextLayoutManagerDelegate {
  
  // MARK: - NSTextLayoutManagerDelegate
  
  func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                         textLayoutFragmentFor location: NSTextLocation,
                         in textElement: NSTextElement) -> NSTextLayoutFragment {
    let index = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)
    let commentDepthValue = textContentStorage!.textStorage!.attribute(.commentDepth, at: index, effectiveRange: nil) as! NSNumber?
    if commentDepthValue != nil {
      let layoutFragment = BubbleLayoutFragment(textElement: textElement, range: textElement.elementRange)
      layoutFragment.commentDepth = commentDepthValue!.uintValue
      return layoutFragment
    } else {
      return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
  }
}


public class MarkdownTextView: NSTextView {
  
//  let parser = MarkdownParser()
  
  var blocks: [MarkdownBlock] = []
  var rangeIndex: [NSTextRange: MarkdownBlock] = [:]
  var processingTask: Task<Void, Never>?
  
  let heightHandler = Debouncer(interval: 0.7)
  let scrollHandler = Debouncer()
  
  let infoHandler = EditorInfoHandler()

  var configuration: EditorConfiguration
  
  var editorInfo = EditorInfo()
  
  
  private var viewportLayoutController: NSTextViewportLayoutController?
  var viewportDelegate: CustomViewportDelegate?
  
  var processingTime: Double = .zero
  
//  var scrollOffset: CGFloat = .zero {
//    didSet {
//      if scrollOffset != oldValue {
//        didChangeScroll()
//      }
//    }
//  }
  
  //  public typealias OnEvent = (_ event: NSEvent, _ action: () -> Void) -> Void
//  public var onKeyDown: OnEvent = { $1() }
//  public var onFlagsChanged: OnEvent = { $1() }
//  public var onMouseDown: OnEvent = { $1() }
  
  public var onInfoUpdate: MarkdownEditor.InfoUpdate = { _ in }
  
  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    configuration: EditorConfiguration = .init()
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
    textLayoutManager.textContainer = container
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    container.containerSize = NSSize(width: frameRect.width, height: CGFloat.greatestFiniteMagnitude) 
    
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
  
}

extension Notification.Name {
  static let metricsDidChange = Notification.Name("metricsDidChange")
}


extension MarkdownTextView {

  func setupViewportLayoutController() {
    guard let textLayoutManager = self.textLayoutManager else { return }
    
    self.viewportDelegate = CustomViewportDelegate()
    self.viewportDelegate?.textView = self
    
    self.viewportLayoutController = NSTextViewportLayoutController(textLayoutManager: textLayoutManager)
    self.viewportLayoutController?.delegate = viewportDelegate
  }

  func testStyles() {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage
    else { return }
    
    let documentRange = tlm.documentRange
    
    var codeBlockCount = 0
    
    // Enumerate through text paragraphs
    tcm.enumerateTextElements(from: documentRange.location, options: []) { textElement in
      guard let paragraph = textElement as? NSTextParagraph else { return true }
      
      // Get the content of the paragraph
      let paragraphRange = paragraph.elementRange
      guard let content = tcm.attributedString(in: paragraphRange)?.string else { return true }
      
      // Check if the paragraph starts with three backticks
      if content.hasPrefix("```") {
        codeBlockCount += 1
      }
      
      return true
    }
    tcm.performEditingTransaction {
      
    }
  }
  
  
  
//  public override func layout() {
//    super.layout()
//    //    updateViewport()
//  }
//  
  
  
//  public override func keyDown(with event: NSEvent) {
//    onKeyDown(event) {
//      super.keyDown(with: event)
//    }
//  }
//  
//  public override func flagsChanged(with event: NSEvent) {
//    onFlagsChanged(event) {
//      super.flagsChanged(with: event)
//    }
//  }
//  
//  public override func mouseDown(with event: NSEvent) {
//    onMouseDown(event) {
//      super.mouseDown(with: event)
//    }
//  }
  
  public override func draw(_ rect: NSRect) {
    super.draw(rect)
    
    if configuration.isShowingFrames {
      let border:NSBezierPath = NSBezierPath(rect: bounds)
      let borderColor = NSColor.red.withAlphaComponent(0.08)
      borderColor.set()
      border.lineWidth = 1.0
      border.fill()
    }
  }
}
