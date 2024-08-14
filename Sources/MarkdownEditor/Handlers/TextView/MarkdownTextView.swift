//
//  File.swift
//
//
//  Created by Dave Coleman on 10/8/2024.
//

import SwiftUI
import STTextKitPlus


public class MarkdownTextView: NSTextView {
  
  var inlineCodeElements: [InlineCodeElement] = []
  
  public typealias OnEvent = (_ event: NSEvent, _ action: () -> Void) -> Void
  
  private var activeScrollValue: (NSRange, CGSize)?
  
  private var lastSelectionValue = [NSValue]()
  private var lastTextValue = String()
  
  public var onKeyDown: OnEvent = { $1() }
  public var onFlagsChanged: OnEvent = { $1() }
  public var onMouseDown: OnEvent = { $1() }
  
  public typealias SelectionChangeHandler = (_ selectionInfo: EditorInfo.Selection) -> Void
  public var onSelectionChange: SelectionChangeHandler = { _ in }
  
  public typealias TextChangeHandler = (_ textInfo: EditorInfo.Text) -> Void
  public var onTextChange: TextChangeHandler = { _ in }
  
  //  let parser: MarkdownParser

  /// Deliver `NSTextView.didChangeSelectionNotification` for all selection changes.
  ///
  /// See the documenation for `setSelectedRanges(_:affinity:stillSelecting:)` for details.
  public var continuousSelectionNotifications: Bool = false
  
  public override init(
    frame frameRect: NSRect = .zero,
    textContainer container: NSTextContainer? = nil
  ) {
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
  
  
  public override var intrinsicContentSize: NSSize {
    textLayoutManager?.usageBoundsForTextContainer.size ?? .zero
  }
  
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


public struct EditorInfo {
  
  
  public struct Text {
    let editorHeight: CGFloat
    let characterCount: Int
    let textElementCount: Int
    let documentRange: NSTextRange
    
    public var summary: String {
            """
            Editor Height: \(String(format: "%.2f", editorHeight))
            Character Count: \(characterCount)
            Text Element Count: \(textElementCount)
            Document Range: \(documentRange)
            """
    }
  }
  
  public struct Selection {
    let selectedRange: NSRange
    let lineNumber: Int
    let columnNumber: Int
    let selectedText: String
    
    public var summary: String {
            """
            Selected Range: \(selectedRange)
            Line: \(lineNumber), Column: \(columnNumber)
            Selected Text: "\(selectedText)"
            """
    }
    
    public static func summaryFor(selection: Selection) -> String {
      selection.summary
    }


  }
  
  public static func fullSummary(text: Text, selection: Selection) -> String {
        """
        Text Info:
        \(text.summary)
        
        Selection Info:
        \(selection.summary)
        """
  }
  
}



extension MarkdownTextView {
  
  private func calculateTextInfo() -> EditorInfo.Text? {
    
    guard let documentRange = self.textLayoutManager?.documentRange else { return nil }
    
    var textElementCount: Int = 0
    
    textLayoutManager?.textContentManager?.enumerateTextElements(from: documentRange.location, using: { _ in
      textElementCount += 1
      return true
    })
    
    return EditorInfo.Text(
      editorHeight: self.intrinsicContentSize.height + 120,
      characterCount: self.string.count,
      textElementCount: textElementCount,
      documentRange: documentRange
    )
  }
  
  private func calculateSelectionInfo() -> EditorInfo.Selection {
    let selectedRange = self.selectedRange()
    let fullString = self.string as NSString
    let substring = fullString.substring(to: selectedRange.location)
    let lineNumber = substring.components(separatedBy: .newlines).count
    
    let lineRange = fullString.lineRange(for: NSRange(location: selectedRange.location, length: 0))
    let lineStart = lineRange.location
    let columnNumber = selectedRange.location - lineStart + 1
    
    let selectedText = fullString.substring(with: selectedRange)
    
    return EditorInfo.Selection(
      selectedRange: selectedRange,
      lineNumber: lineNumber,
      columnNumber: columnNumber,
      selectedText: selectedText
    )
  }
  
  
  public override func didChangeText() {
    super.didChangeText()
    self.invalidateIntrinsicContentSize()
    
    if self.string != lastTextValue {
      lastTextValue = self.string
      guard let textInfo = calculateTextInfo() else { return }
      onTextChange(textInfo)
    }
    
  }
  
  public override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting: Bool) {
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelecting)
    
    if ranges != lastSelectionValue {
      lastSelectionValue = ranges
      let selectionInfo = calculateSelectionInfo()
      onSelectionChange(selectionInfo)
    }
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
}
