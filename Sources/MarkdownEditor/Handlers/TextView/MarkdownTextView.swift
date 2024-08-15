//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
//import STTextKitPlus


public class MarkdownTextView: NSTextView {
  
  private var viewportLayoutController: NSTextViewportLayoutController?
  private var viewportDelegate: CustomViewportDelegate?
  
  var isShowingFrames: Bool
  var textInsets: CGFloat
  
  //  var inlineCodeElements: [InlineCodeElement] = []
  
  var markdownBlocks: [MarkdownBlock] = []
  
  public typealias OnEvent = (_ event: NSEvent, _ action: () -> Void) -> Void
  
  private var activeScrollValue: (NSRange, CGSize)?
  
  var lastTextValue = String()
  
  public var onKeyDown: OnEvent = { $1() }
  public var onFlagsChanged: OnEvent = { $1() }
  public var onMouseDown: OnEvent = { $1() }
  
  public var onTextChange: MarkdownEditor.TextInfo = { _ in }
  public var onSelectionChange: MarkdownEditor.SelectionInfo = { _ in }
  public var onEditorHeightChange: MarkdownEditor.EditorHeight = { _ in }
  
  public init(
    frame frameRect: NSRect,
    textContainer container: NSTextContainer?,
    isShowingFrames: Bool,
    textInsets: CGFloat
  ) {
    
    self.isShowingFrames = isShowingFrames
    self.textInsets = textInsets
        
    let textLayoutManager = MarkdownLayoutManager()
    let textContentStorage = NSTextContentStorage()
    let container = NSTextContainer()
    
    textLayoutManager.textContainer = container
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    
    super.init(frame: frameRect, textContainer: container)
    
    self.textViewSetup()

  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  //
  //  func parseInlineCode() {
  //    guard let textContentManager = self.textLayoutManager?.textContentManager else { return }
  //
  //    inlineCodeElements.removeAll()
  //
  ////    let fullRange = NSRange(location: 0, length: string.utf16.count)
  //    let regex = Markdown.Syntax.inlineCode.regex
  //
  //    regex.
  //
  //    regex.enumerateMatches(in: string, options: [], range: fullRange) { match, _, _ in
  //      if let matchRange = match?.range {
  //        let element = InlineCodeElement(range: matchRange)
  //        inlineCodeElements.append(element)
  //
  //        textContentManager.performEditingTransaction {
  //          textContentManager.addTextElement(element, for: NSTextRange(matchRange, in: textContentManager))
  //        }
  //      }
  //    }
  //
  //    print("Found \(inlineCodeElements.count) inline code elements")
  //  }
  //
  //
  
  
  public override var layoutManager: NSLayoutManager? {
    assertionFailure("TextKit 1 is not supported by this type")
    return nil
  }

}

extension Notification.Name {
  static let metricsDidChange = Notification.Name("metricsDidChange")
}


extension MarkdownTextView {
  
  var editorHeight: CGFloat {
    
    guard let tlm = self.textLayoutManager
    else { return .zero }
    let documentRange = tlm.documentRange
    let typographicBounds: CGFloat = tlm.typographicBounds(in: documentRange)?.height ?? .zero
    let height = (textInsets * 2) + typographicBounds
    
    return height
  }
  
  private func setupViewportLayoutController() {
    guard let textLayoutManager = self.textLayoutManager else { return }
    
    viewportDelegate = CustomViewportDelegate()
    viewportDelegate?.textView = self
    
    viewportLayoutController = NSTextViewportLayoutController(textLayoutManager: textLayoutManager)
    viewportLayoutController?.delegate = viewportDelegate
    
    // Set the initial viewport
//        viewportLayoutController?.viewportRange = self.visibleRange
  }
  
  //  private func updateViewport() {
  //    viewportLayoutController?.viewportRange = self.visibleRange
  //  }
  
  public override func scrollWheel(with event: NSEvent) {
    super.scrollWheel(with: event)
    //    updateViewport()
  }
  
  func testStyles() {
    
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let tcs = self.textContentStorage
    else { return }
    
//    let testAttrs: [NSAttributedString.Key: Any] = [
//      .foregroundColor: NSColor.yellow
//    ]
//    
    let documentRange = tlm.documentRange
    
    var codeBlockCount = 0
    
//    let nsRange = NSRange(documentRange, in: tcm)
    
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
    
//    self.string.range
    
    //    guard let fullString = tcs.attributedString(in: documentRange)?.string else { return }
    
    tcm.performEditingTransaction {
      
        
      

//      var ranges: [NSTextRange] = []
      
      
      
//      for range in ranges {
        
        //        tcs.textStorage?.setAttributes(testAttrs, range: nsRange)
        
        
//      }
      
    }
  }
  
  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    self.onTextChange(calculateTextInfo())
    self.onEditorHeightChange(self.editorHeight)
    
    setupViewportLayoutController()
    
    self.testStyles()
    
    self.markdownBlocks = self.processMarkdownBlocks(highlight: true)
    
  }
  
  public override func layout() {
    super.layout()
    //    updateViewport()
  }
  
  
  
  public override func keyDown(with event: NSEvent) {
    onKeyDown(event) {
      super.keyDown(with: event)
    }
  }
  
  public override func flagsChanged(with event: NSEvent) {
    onFlagsChanged(event) {
      super.flagsChanged(with: event)
    }
  }
  
  public override func mouseDown(with event: NSEvent) {
    onMouseDown(event) {
      super.mouseDown(with: event)
    }
  }
  
  public override func draw(_ rect: NSRect) {
    super.draw(rect)
    
    if isShowingFrames {
      let border:NSBezierPath = NSBezierPath(rect: bounds)
      let borderColor = NSColor.red.withAlphaComponent(0.08)
      borderColor.set()
      border.lineWidth = 1.0
      border.fill()
    }
  }
}
