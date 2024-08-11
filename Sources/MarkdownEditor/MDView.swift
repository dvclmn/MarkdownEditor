//
//  File.swift
//
//
//  Created by Dave Coleman on 11/8/2024.
//

import SwiftUI

public final class MarkdownView: NSView {
  
  weak var delegate: NSTextViewDelegate?
  
  var attributedText: NSAttributedString {
    didSet {
      textView.textStorage?.setAttributedString(attributedText)
    }
  }
  
  var selectedRanges: [NSValue] = [] {
    didSet {
      guard selectedRanges.count > 0 else {
        return
      }
      
      textView.selectedRanges = selectedRanges
    }
  }
  
  public lazy var scrollView: NSScrollView = {
    let scrollView = NSScrollView()
    scrollView.drawsBackground = false
    scrollView.borderType = .noBorder
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalRuler = false
    scrollView.autoresizingMask = [.width, .height]
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    return scrollView
  }()
  
  public lazy var textView: MDTextView = {
    let contentSize = scrollView.contentSize
    let textStorage = NSTextStorage()
    
    let layoutManager = NSLayoutManager()
    textStorage.addLayoutManager(layoutManager)
    
    let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
    
    textContainer.widthTracksTextView = true
    textContainer.containerSize = NSSize(
      width: contentSize.width,
      height: CGFloat.greatestFiniteMagnitude
    )
    
    layoutManager.addTextContainer(textContainer)
    
    let textView = MDTextView(frame: .zero, textContainer: textContainer)
    
    textView.autoresizingMask = .width
    textView.backgroundColor = NSColor.textBackgroundColor
    textView.delegate = self.delegate
    textView.drawsBackground = false
    textView.isHorizontallyResizable = false
    textView.isVerticallyResizable = true
    textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    textView.minSize = NSSize(width: 0, height: contentSize.height)
    textView.allowsUndo = true
    textView.isRichText = false
    textView.textContainer?.lineFragmentPadding = 30
    textView.textContainerInset = NSSize(width: 0, height: 30)
    
    
    return textView
  }()
  
  var editorHeight: CGFloat? = nil
  
  // MARK: - Init
  
  init() {
    self.attributedText = NSMutableAttributedString()
    
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life cycle
  
  override public func viewWillDraw() {
    super.viewWillDraw()
    
    setupScrollViewConstraints()
    setupTextView()
    
    self.editorHeight = self.textView.intrinsicContentSize.height
  }
  
  func setupScrollViewConstraints() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])
  }
  
  func setupTextView() {
    scrollView.documentView = textView
    /// This initially sets the colour to yellow, then immediately gets overriden on text edit
    //         textView.textColor = NSColor.yellow
  }
  
}
