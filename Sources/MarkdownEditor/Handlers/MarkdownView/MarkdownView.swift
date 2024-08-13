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
  
  /// The manager that lays out text for the text view's text container.
  private(set) var textLayoutManager: NSTextLayoutManager
  
  /// The text view's text storage object.
  private(set) var textContentManager: NSTextContentManager
  
  /// The text view's text container
  public var textContainer: NSTextContainer {
    get {
      textLayoutManager.textContainer!
    }
    
    set {
      textLayoutManager.textContainer = newValue
    }
  }
  
  
  
  public override var intrinsicContentSize: NSSize {
    textLayoutManager.usageBoundsForTextContainer.size
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
  func setTextColor(_ color: NSColor?, range: NSRange) {
    if let color {
      addAttributes([.foregroundColor: color], range: range)
    } else {
      removeAttribute(.foregroundColor, range: range)
    }
  }
  
  /// The receiver’s default paragraph style.
  dynamic public var defaultParagraphStyle: NSParagraphStyle? {
    didSet {
      textView.typingAttributes[.paragraphStyle] = defaultParagraphStyle ?? .default
    }
  }
  
  var defaultTypingAttributes: [NSAttributedString.Key: Any] {
    [
      .paragraphStyle: self.defaultParagraphStyle ?? NSParagraphStyle.default,
      .font: NSFont.userFont(ofSize: 0) ?? .preferredFont(forTextStyle: .body),
      .foregroundColor: NSColor.textColor
    ]
  }
  
  
  //  var font: Font? { get set }
  //  var textColor: Color? { get set }
  //  var text: String? { get set }
  //  var attributedText: NSAttributedString? { get set }
  //
  //
  //  var defaultParagraphStyle: NSParagraphStyle? { get set }
  //  var typingAttributes: [NSAttributedString.Key: Any] { get set }
  //  var gutterView: RulerView? { get }
  //  var allowsUndo: Bool { get set }
  //
  //  var textDelegate: Delegate? { get set }
  //
  //  func toggleRuler(_ sender: Any?)
  //  var isRulerVisible: Bool { get set }
  //
  //  func setSelectedTextRange(_ textRange: NSTextRange)
  //
  //  func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange, updateLayout: Bool)
  //  func addAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSTextRange, updateLayout: Bool)
  //
  //  func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSRange, updateLayout: Bool)
  //  func setAttributes(_ attrs: [NSAttributedString.Key: Any], range: NSTextRange, updateLayout: Bool)
  //
  //  func removeAttribute(_ attribute: NSAttributedString.Key, range: NSRange, updateLayout: Bool)
  //  func removeAttribute(_ attribute: NSAttributedString.Key, range: NSTextRange, updateLayout: Bool)
  //
  //  func shouldChangeText(in affectedTextRange: NSTextRange, replacementString: String?) -> Bool
  //  func replaceCharacters(in range: NSTextRange, with string: String)
  //  func insertText(_ string: Any, replacementRange: NSRange)
  
  
  
  
  
  weak var delegate: NSTextContentStorageDelegate?
  
  
  /// The characters of the receiver’s text.
  ///
  /// For performance reasons, this value is the current backing store of the text object.
  /// If you want to maintain a snapshot of this as you manipulate the text storage, you should make a copy of the appropriate substring.
  public var text: String? {
    set {
      let prevLocation = textLayoutManager.insertionPointLocations.first
      
      setString(newValue)
      
      if let prevLocation {
        // restore selection location
        setSelectedTextRange(NSTextRange(location: prevLocation))
      } else {
        // or try to set at the begining of the document
        setSelectedTextRange(NSTextRange(location: textContentManager.documentRange.location))
      }
    }
    get {
      textContentManager.attributedString(in: nil)?.string ?? ""
    }
  }
  
  /// The styled text that the text view displays.
  ///
  /// Assigning a new value to this property also replaces the value of the `text` property with the same string data, albeit without any formatting information. In addition, the `font`, `textColor`, and `textAlignment` properties are updated to reflect the typing attributes of the text view.
  public var attributedText: NSAttributedString? {
    set {
      let prevLocation = textLayoutManager.insertionPointLocations.first
      
      setString(newValue)
      
      if let prevLocation {
        // restore selection location
        setSelectedTextRange(NSTextRange(location: prevLocation))
      } else {
        // or try to set at the begining of the document
        setSelectedTextRange(NSTextRange(location: textContentManager.documentRange.location))
      }
    }
    get {
      textContentManager.attributedString(in: nil)
    }
  }
  
  
  
  internal func setString(_ string: Any?) {
    undoManager?.disableUndoRegistration()
    defer {
      undoManager?.enableUndoRegistration()
    }
    
    switch string {
      case let string as String:
        replaceCharacters(in: textLayoutManager.documentRange, with: string, useTypingAttributes: true, allowsTypingCoalescing: false)
      case let attributedString as NSAttributedString:
        replaceCharacters(in: textLayoutManager.documentRange, with: attributedString, allowsTypingCoalescing: false)
      case .none:
        replaceCharacters(in: textLayoutManager.documentRange, with: "", useTypingAttributes: true, allowsTypingCoalescing: false)
      default:
        return assertionFailure()
    }
  }
  
  internal func replaceCharacters(in textRange: NSTextRange, with replacementString: String, useTypingAttributes: Bool, allowsTypingCoalescing: Bool) {
    self.replaceCharacters(
      in: textRange,
      with: NSAttributedString(string: replacementString, attributes: useTypingAttributes ? textView.typingAttributes : [:]),
      allowsTypingCoalescing: allowsTypingCoalescing
    )
  }
  
  internal func replaceCharacters(in textRange: NSTextRange, with replacementString: NSAttributedString, allowsTypingCoalescing: Bool) {
    let previousStringInRange = (textContentManager as? NSTextContentStorage)!.attributedString!.attributedSubstring(from: NSRange(textRange, in: textContentManager))
    
//    textWillChange(self)
//    delegateProxy.textView(self, willChangeTextIn: textRange, replacementString: replacementString.string)
    
    textContentManager.performEditingTransaction {
      textContentManager.replaceContents(
        in: textRange,
        with: [NSTextParagraph(attributedString: replacementString)]
      )
    }
    
//    delegateProxy.textView(self, didChangeTextIn: textRange, replacementString: replacementString.string)
//    didChangeText(in: textRange)
    
//    guard allowsUndo, let undoManager = undoManager, undoManager.isUndoRegistrationEnabled else { return }
    
    // Reach to NSTextStorage because NSTextContentStorage range extraction is cumbersome.
    // A range that is as long as replacement string, so when undo it undo
    let undoRange = NSTextRange(
      location: textRange.location,
      end: textContentManager.location(textRange.location, offsetBy: replacementString.length)
    ) ?? textRange
    
//    if let coalescingUndoManager = undoManager as? CoalescingUndoManager, !undoManager.isUndoing, !undoManager.isRedoing {
//      if allowsTypingCoalescing && processingKeyEvent {
//        coalescingUndoManager.checkCoalescing(range: undoRange)
//      } else {
//        coalescingUndoManager.endCoalescing()
//      }
//    }
//    undoManager.beginUndoGrouping()
//    undoManager.registerUndo(withTarget: self) { textView in
      // Regular undo action
      textView.replaceCharacters(
        in: undoRange,
        with: previousStringInRange,
        allowsTypingCoalescing: false
      )
      textView.setSelectedTextRange(textRange)
    }
    undoManager.endUndoGrouping()
  }
  
  
  //  var parser: MarkdownParser
  
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
  
  
@MainActor
public var textView: MarkdownTextView = {
    let textView = MarkdownTextView(
      frame: bounds,
      textContainer: textLayoutManager.textContainer
    )
    textView.isEditable = true
    textView.isSelectable = true
    textView.allowsUndo = true
    return textView
  }()
  
  var editorHeight: CGFloat? = nil
  
  // MARK: - Init
  init(
    
  ) {
    
    textContentManager = MarkdownContentStorage()
    textLayoutManager = MarkdownLayoutManager()
    
    
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
    setupViews()
    self.editorHeight = self.textView.intrinsicContentSize.height
  }
  
}
