//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import STTextKitPlus


public class MarkdownTextView: NSTextView {
  
  var editorHeight: CGFloat = .zero
  var isShowingFrames: Bool
  
  var inlineCodeElements: [InlineCodeElement] = []
  
  public typealias OnEvent = (_ event: NSEvent, _ action: () -> Void) -> Void
  
  private var activeScrollValue: (NSRange, CGSize)?
  
  var lastSelectionValue = [NSValue]()
  var lastTextValue = String()
  
  public var onKeyDown: OnEvent = { $1() }
  public var onFlagsChanged: OnEvent = { $1() }
  public var onMouseDown: OnEvent = { $1() }
  
  public typealias TextChangeHandler = (_ textInfo: EditorInfo.Text) -> Void
  public var onTextChange: TextChangeHandler = { _ in }

  public typealias SelectionChangeHandler = (_ selectionInfo: EditorInfo.Selection) -> Void
  public var onSelectionChange: SelectionChangeHandler = { _ in }
  

  //  let parser: MarkdownParser
  
  /// Deliver `NSTextView.didChangeSelectionNotification` for all selection changes.
  ///
  /// See the documenation for `setSelectedRanges(_:affinity:stillSelecting:)` for details.
  public var continuousSelectionNotifications: Bool = false
  
  public init(
    frame frameRect: NSRect = .zero,
    textContainer container: NSTextContainer? = nil,
    isShowingFrames: Bool = false
  ) {
    
    self.isShowingFrames = isShowingFrames
    //    self.parser = MarkdownParser()
    
    let container = NSTextContainer()
    
    let textLayoutManager = MarkdownLayoutManager()
    
    textLayoutManager.textContainer = container
    
    let textContentStorage = MarkdownContentStorage()
    
    textContentStorage.addTextLayoutManager(textLayoutManager)
    textContentStorage.primaryTextLayoutManager = textLayoutManager
    
    super.init(frame: frameRect, textContainer: container)
    
    self.textViewSetup()
    
    //    self.parser.text = self.string
    
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
  //    let regex = MarkdownSyntax.inlineCode.regex
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
  
  
//  public override var intrinsicContentSize: NSSize {
//    textLayoutManager?.usageBoundsForTextContainer.size ?? .zero
//  }
//  
  //  func assembleMetrics() {
  //    guard let documentRange = self.textLayoutManager?.documentRange else { return }
  //
  //    var textElementCount: Int = 0
  //
  //    textLayoutManager?.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
  //      textElementCount += 1
  //      return true
  //    })
  //
  ////    DispatchQueue.main.async {
  //      self.editorMetrics = """
  //      Editor height: \(self.intrinsicContentSize.height.description)
  //      Character count: \(self.string.count)
  //      Text elements: \(textElementCount.description)
  //      Document range: \(documentRange.description)
  //      """
  ////    }
  //    NotificationCenter.default.post(name: .metricsDidChange, object: self)
  //
  //  }
  
}

extension Notification.Name {
  static let metricsDidChange = Notification.Name("metricsDidChange")
}




extension MarkdownTextView {
  

 
  public override var intrinsicContentSize: NSSize {
    
    guard let textLayoutManager = self.textLayoutManager,
            let container = self.textContainer else {
      return super.intrinsicContentSize
    }
//    container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
    textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
    
    let rect = textLayoutManager.usageBoundsForTextContainer
    
    let bufferHeight: CGFloat = self.isEditable ? 120 : 0
    let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: rect.height + bufferHeight)
    
//    self.editorHeight = bounds.height
    
    return contentSize
  }
  
  func updateEditorHeight() {
//    self.invalidateIntrinsicContentSize()
//    self.needsLayout = true
//    self.needsDisplay = true
    
    
    
  }
  
  
  public override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    self.onTextChange(calculateTextInfo())
    self.updateEditorHeight()
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
