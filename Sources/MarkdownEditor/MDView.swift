//
//  File.swift
//
//
//  Created by Dave Coleman on 11/8/2024.
//

import SwiftUI

@MainActor
public final class MarkdownView: NSView {
  
  weak var delegate: NSTextViewDelegate?
  
  var attributedText: NSAttributedString {
    didSet {
      
      textContentStorage.performEditingTransaction {
        textContentStorage.textStorage?.setAttributedString(attributedText)
      }
    }
  }
  
  
//  var attributedText: NSAttributedString {
//    get {
//      textContentStorage.attributedString!
//    }
//    set {
//      textContentStorage.performEditingTransaction {
//        self.textContentStorage.attributedString = newValue
//      }
//    }
//  }

  var selectedRanges: [NSValue] = [] {
    didSet {
      guard selectedRanges.count > 0 else { return }
      
      textView.selectedRanges = selectedRanges
    }
  }
  
  public lazy var scrollView: NSScrollView = {
    let scrollView = NSScrollView()
    scrollView.documentView = textView
    return scrollView
  }()
  
  /// The primary class that you use to manage text layout and presentation for custom text displays.
  ///
  /// `NSTextLayoutManager` is the centerpiece of the TextKit object network that
  /// maintains the layout geometry through an array of `NSTextContainer` objects.
  /// It lays out results using `NSTextLayoutFragment` and `NSTextElement` objects
  /// vended from a `NSTextContentManager` that participates in the content layout process.
  ///
  ///How to access these:
  /// On the `NSView`:
  /// `self.textContentStorage`
  /// `self.textLayoutManager`
  /// `self.textContainer`
  ///
  /// On the `NSTextView`
  /// `self.textView.isEditable`
  /// `self.textView.font`
  ///
  private lazy var textLayoutManager: NSTextLayoutManager = {
    let layoutManager = MarkdownLayoutManager()
    return layoutManager
  }()
  
  private lazy var textContainer: NSTextContainer = {
    let containerSize = NSSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
    let container = NSTextContainer(size: containerSize)
    container.widthTracksTextView = true
    textLayoutManager.textContainer = container
    return container
  }()
  
  private lazy var textContentStorage: NSTextContentStorage = {
    let storage = NSTextContentStorage()
    storage.addTextLayoutManager(textLayoutManager)
    return storage
  }()
  
  public lazy var textView: NSTextView = {
    let textView = MDTextView(frame: bounds, textContainer: textContainer)
    textView.isEditable = true
    textView.isSelectable = true
    textView.allowsUndo = true
    textView.delegate = delegate
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
  
  private func setupViews() {
    
    /// Scroll view
    ///
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    scrollView.borderType = .noBorder
    addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.documentView = textView
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
    /// Text view
    ///
    textView.autoresizingMask = .width
    textView.backgroundColor = NSColor.textBackgroundColor
    textView.delegate = self.delegate
    textView.drawsBackground = false
    textView.isHorizontallyResizable = false
    textView.isVerticallyResizable = true
    textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    textView.allowsUndo = true
    textView.isRichText = false
    textView.textContainer?.lineFragmentPadding = 30
    textView.textContainerInset = NSSize(width: 0, height: 30)
  }
  
  
  
  // MARK: - Life cycle
  
  override public func viewWillDraw() {
    super.viewWillDraw()

    self.editorHeight = self.textView.intrinsicContentSize.height
  }

}
