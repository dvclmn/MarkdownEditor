//
//  File.swift
//
//
//  Created by Dave Coleman on 11/8/2024.
//

import SwiftUI
import STTextKitPlus

public final class MarkdownView: NSView {
  
  /// Sent when the text in the receiving control changes.
  public static let textDidChangeNotification = NSText.didChangeNotification
  
  /// Sent when the selection range of characters changes.
  public static let didChangeSelectionNotification = MarkdownLayoutManager.didChangeSelectionNotification
  
  /// A Boolean value that controls whether the text view allows the user to edit text.
  
  dynamic public var isEditable: Bool = true {
    didSet {
      if isEditable == true {
        isSelectable = true
      }
    }
  }
  
  dynamic public var isSelectable: Bool = true {
    didSet {
      if isSelectable == false {
        isEditable = false
      }
    }
  }
  

  /// The text color of the text view.
  dynamic var textColor: NSColor? {
    get {
      textView.typingAttributes[.foregroundColor] as? NSColor
    }
    
    set {
      textView.typingAttributes[.foregroundColor] = newValue
    }
  }
  
  /// Sets the text color of characters within the specified range to the specified color.
//  func setTextColor(_ color: NSColor?, range: NSRange) {
//    if let color {
//      addAttributes([.foregroundColor: color], range: range)
//    } else {
//      removeAttribute(.foregroundColor, range: range)
//    }
//  }
  
  /// The receiver’s default paragraph style.
//  dynamic public var defaultParagraphStyle: NSParagraphStyle? {
//    didSet {
//      textView.typingAttributes[.paragraphStyle] = defaultParagraphStyle ?? .default
//    }
//  }
//  
//  var defaultTypingAttributes: [NSAttributedString.Key: Any] {
//    [
//      .paragraphStyle: self.defaultParagraphStyle ?? NSParagraphStyle.default,
//      .font: NSFont.userFont(ofSize: 0) ?? .preferredFont(forTextStyle: .body),
//      .foregroundColor: NSColor.textColor
//    ]
//  }
  
  
  
  weak var delegate: NSTextContentStorageDelegate?
  
  
  
  //  var selectedRanges: [NSValue] = [] {
  //    didSet {
  //      guard selectedRanges.count > 0 else { return }
  //
  //      textView.selectedRanges = selectedRanges
  //    }
  //  }
  
  
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
  
  //  private lazy var textContainer: NSTextContainer = {
  //    let containerSize = NSSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
  //    let container = NSTextContainer(size: containerSize)
  //    container.widthTracksTextView = true
  //    textLayoutManager.textContainer = container
  //    return container
  //  }()
  //
  //  lazy var textContentStorage: NSTextContentStorage = {
  //    let storage = NSTextContentStorage()
  //    storage.delegate = self.delegate
  //    storage.addTextLayoutManager(textLayoutManager)
  //    return storage
  //  }()
  
  let textView: MarkdownTextView

//  public lazy var textView: MarkdownTextView = {
//    let textView = MarkdownTextView(
//      frame: bounds,
//      textContainer: textLayoutManager.textContainer
//    )
//    textView.isEditable = true
//    textView.isSelectable = true
//    textView.allowsUndo = true
//    return textView
//  }()
  
  var editorHeight: CGFloat? = nil
  
  // MARK: - Init
  init(
    
  ) {
    textView = MarkdownTextView()
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
    scrollView.drawsBackground = false
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    

  }
  
  
  // MARK: - Life cycle
  
  override public func viewWillDraw() {
    super.viewWillDraw()
    setupViews()
    self.editorHeight = self.textView.intrinsicContentSize.height
    
  }
  
}
