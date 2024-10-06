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
      print("Frame width was different from old width (\(oldWidth)).")
      
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


extension MarkdownTextView {
  
  func drawRoundedRect(
    around range: NSRange,
    cornerRadius: CGFloat = 5.0,
    lineWidth: CGFloat = 2.0,
    color: NSColor = .red
  ) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let nsTextRange = NSTextRange(range, scopeRange: tcm.documentRange, provider: tcm)
    else {
      print("Issue with one of the above, bummer")
      return
    }
    
    print("Let's try and draw a rect around a range. Range: \(range)")
    
    // Create a path for the rounded rectangle
    let path = NSBezierPath()
    var isFirstRect = true
    var lastRect: NSRect?
    

    // Enumerate through the text segments in the range
    tlm.enumerateTextSegments(
      in: nsTextRange,
      type: .standard,
      options: []
    ) { (range, segmentFrame, baselinePosition, textContainer) in
      var rect = segmentFrame
      
      // Convert rect to view coordinates
      rect = self.convert(rect, from: nil)
      
      // Adjust rect to account for line width
      rect = rect.insetBy(dx: -lineWidth / 2, dy: -lineWidth / 2)
      
      if isFirstRect {
        path.move(to: NSPoint(x: rect.minX, y: rect.minY + cornerRadius))
        isFirstRect = false
      }
      
      // Draw rounded corners for top-left and top-right of first rectangle
      if lastRect == nil {
        path.line(to: NSPoint(x: rect.minX, y: rect.maxY - cornerRadius))
        path.appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 180,
                       endAngle: 90,
                       clockwise: true)
        
        path.line(to: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        path.appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 90,
                       endAngle: 0,
                       clockwise: true)
      } else {
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
      }
      
      path.line(to: NSPoint(x: rect.maxX, y: rect.minY))
      
      lastRect = rect
      return true
    }
    
    // Draw rounded corners for bottom-right and bottom-left of last rectangle
    if let lastRect = lastRect {
      path.line(to: NSPoint(x: lastRect.maxX, y: lastRect.minY + cornerRadius))
      path.appendArc(withCenter: NSPoint(x: lastRect.maxX - cornerRadius, y: lastRect.minY + cornerRadius),
                     radius: cornerRadius,
                     startAngle: 0,
                     endAngle: -90,
                     clockwise: true)
      
      path.line(to: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY))
      path.appendArc(withCenter: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY + cornerRadius),
                     radius: cornerRadius,
                     startAngle: -90,
                     endAngle: 180,
                     clockwise: true)
    }
    
    path.close()
    
    // Set the drawing attributes
    color.setStroke()
    path.lineWidth = lineWidth
    
    // Draw the path
    path.stroke()
  }
}

/// Usage: `textView.addRoundedRectHighlight(around: range)`
///
class TextHighlightView: NSView {
  var highlightPath: NSBezierPath?
  var highlightColor: NSColor = .red
  var lineWidth: CGFloat = 2.0
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    guard let path = highlightPath else { return }
    
    highlightColor.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
  }
}

extension MarkdownTextView {
  
  func addRoundedRectHighlight(
    around range: NSRange,
    cornerRadius: CGFloat = 5.0,
    lineWidth: CGFloat = 2.0,
    color: NSColor = .red
  ) {
    guard let tlm = self.textLayoutManager,
          let tcm = tlm.textContentManager,
          let nsTextRange = NSTextRange(range, scopeRange: tcm.documentRange, provider: tcm)
    else {
      print("Issue with one of the above, bummer")
      return
    }
    
    let path = NSBezierPath()
    var isFirstRect = true
    var lastRect: NSRect?
    
    tlm.enumerateTextSegments(
      in: nsTextRange,
      type: .standard,
      options: []
    ) { (range, segmentFrame, baselinePosition, textContainer) in
      
      var rect = segmentFrame
      
      print(
        """
        Let's figure out where these coordinates are.
        
        This is the `segmentFrame`: \(segmentFrame)
        
        
        """
)

      // Convert rect to view coordinates
//      rect = self.convert(rect, from: nil)
      
      // Adjust rect to account for line width
      rect = rect.insetBy(dx: -lineWidth / 2, dy: -lineWidth / 2)
      
      if isFirstRect {
        path.move(to: NSPoint(x: rect.minX, y: rect.minY + cornerRadius))
        isFirstRect = false
      }
      
      // Draw rounded corners for top-left and top-right of first rectangle
      if lastRect == nil {
        path.line(to: NSPoint(x: rect.minX, y: rect.maxY - cornerRadius))
        path.appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 180,
                       endAngle: 90,
                       clockwise: true)
        
        path.line(to: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
        path.appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                       radius: cornerRadius,
                       startAngle: 90,
                       endAngle: 0,
                       clockwise: true)
      } else {
        path.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
      }
      
      path.line(to: NSPoint(x: rect.maxX, y: rect.minY))
      
      lastRect = rect
      return true
    }
    
    // Draw rounded corners for bottom-right and bottom-left of last rectangle
    if let lastRect = lastRect {
      path.line(to: NSPoint(x: lastRect.maxX, y: lastRect.minY + cornerRadius))
      path.appendArc(withCenter: NSPoint(x: lastRect.maxX - cornerRadius, y: lastRect.minY + cornerRadius),
                     radius: cornerRadius,
                     startAngle: 0,
                     endAngle: -90,
                     clockwise: true)
      
      path.line(to: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY))
      path.appendArc(withCenter: NSPoint(x: lastRect.minX + cornerRadius, y: lastRect.minY + cornerRadius),
                     radius: cornerRadius,
                     startAngle: -90,
                     endAngle: 180,
                     clockwise: true)
    }
    
    path.close()
    
    // Create and configure the highlight view
    let highlightView = TextHighlightView(frame: self.bounds)
    highlightView.highlightPath = path
    highlightView.highlightColor = color
    highlightView.lineWidth = lineWidth
    highlightView.autoresizingMask = [.width, .height]
    highlightView.wantsLayer = true
    highlightView.layer?.zPosition = 1
    
    // Add the highlight view as a subview
    self.addSubview(highlightView)
    
    // Ensure the highlight view is below the text
//    self.sendSubviewToBack(highlightView)
  }
}




/// Usage: `textView.highlightTextRange(range)`

class HighlightTextAttachment: NSTextAttachment {
  var highlightColor: NSColor
  var cornerRadius: CGFloat
  
  init(color: NSColor, cornerRadius: CGFloat) {
    self.highlightColor = color
    self.cornerRadius = cornerRadius
    super.init(data: nil, ofType: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func image(
    forBounds imageBounds: CGRect,
    textContainer: NSTextContainer?,
    characterIndex charIndex: Int
  ) -> NSImage? {
    let image = NSImage(size: imageBounds.size)
    image.lockFocus()
    
    let bezierPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: imageBounds.size), xRadius: cornerRadius, yRadius: cornerRadius)
    highlightColor.setFill()
    bezierPath.fill()
    
    image.unlockFocus()
    return image
  }
}

extension MarkdownTextView {
  
  func highlightTextRange(
    _ range: NSRange,
    color: NSColor = .yellow.withAlphaComponent(0.3),
    cornerRadius: CGFloat = 3
  ) {
    
    guard let textStorage = textStorage else { return }
    
    let attachment = HighlightTextAttachment(color: color, cornerRadius: cornerRadius)
    let attachmentChar = NSAttributedString(attachment: attachment)
    
    textStorage.beginEditing()
    
    // Get the rect for the range
    let rangeRect = firstRect(forCharacterRange: range, actualRange: nil)
    
    // Set the size of the attachment to match the text range
    attachment.bounds = CGRect(origin: .zero, size: rangeRect.size)
    
    // Insert the attachment at the start of the range
    textStorage.insert(attachmentChar, at: range.location)
    
    // Extend the original range to include the attachment
    let extendedRange = NSRange(location: range.location, length: range.length + 1)
    
    // Set the baseline offset to position the highlight correctly
    textStorage.addAttribute(.baselineOffset, value: NSNumber(value: -1), range: NSRange(location: range.location, length: 1))
    
    // Ensure the attachment doesn't displace text
    textStorage.addAttribute(.expansion, value: NSNumber(value: -1), range: NSRange(location: range.location, length: 1))
    
    textStorage.endEditing()
  }
}
