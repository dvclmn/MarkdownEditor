//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/2/2025.
//

import AppKit
import MarkdownModels

public class MarkdownScrollView: NSView {
  private let scrollView: NSScrollView
  let textView: MarkdownTextView
  private let minEditorHeight: CGFloat = 80
  
  /// Closure to call when the intrinsic height (of the text view) changes.
  var heightChanged: ((CGFloat) -> Void)?
  
  /// A stored property to throttle height updates.
  private var lastReportedHeight: CGFloat = 0

  public init(
    frame frameRect: NSRect,
    configuration: EditorConfiguration
  ) {
    /// Create text storage and layout manager
    let textStorage = MarkdownTextStorage(configuration: configuration)
    let layoutManager = MarkdownLayoutManager(configuration: configuration)
    textStorage.addLayoutManager(layoutManager)

    /// Create text container
    let textContainer = NSTextContainer(
      containerSize: NSSize(
        width: frameRect.width,
        height: .greatestFiniteMagnitude
      )
    )
    textContainer.widthTracksTextView = true
    layoutManager.addTextContainer(textContainer)

    /// Create text view
    textView = MarkdownTextView(
      frame: frameRect,
      textContainer: textContainer,
      configuration: configuration,
      minHeight: minEditorHeight
    )

    /// Create scroll view
    scrollView = NSScrollView(frame: frameRect)
    scrollView.hasVerticalScroller = configuration.isEditable
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    scrollView.drawsBackground = false
    /// Configure scroll view
    scrollView.documentView = textView

    super.init(frame: frameRect)

    /// Add scroll view as a subview
    addSubview(scrollView)

    /// Ensure that our subviews use autoresizing – or set up Auto Layout constraints here.
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Override layout so that when the view's bounds change, we invalidate and recalc the intrinsic size.
  public override func layout() {
    super.layout()
    
    /// Ensure the scroll view and text view have their frames updated.
    scrollView.frame = self.bounds
//    textView.frame = self.bounds
    
//    /// In non-editable mode we want the text view to report its new natural height.
//    if !textView.isEditable {
//      
//      /// Force a re-layout so that the intrinsicContentSize is recalculated.
//      textView.invalidateIntrinsicContentSize()
//      let newHeight = textView.intrinsicContentSize.height
//      
//      /// Only notify if the height has changed significantly.
//      if abs(newHeight - lastReportedHeight) > 1.0 {
//        lastReportedHeight = newHeight
//        heightChanged?(newHeight)
//      }
//    }
    
    if textView.isEditable {
      /// When editable, let the document view's height be determined by its content.
      guard let layoutManager = textView.layoutManager,
            let textContainer = textView.textContainer else {
        return
      }
      /// Recalculate layout so that `usedRect` is up-to-date.
      layoutManager.ensureLayout(for: textContainer)
      let usedRect = layoutManager.usedRect(for: textContainer)
      
      /// Compute the content height including our text container insets.
      let contentHeight = usedRect.height + (textView.textContainerInset.height * 2)
      
      /// The document view (textView) should be as tall as:
      /// - self.bounds.height if content is short (so the whole visible area is used)
      /// - or contentHeight if the text is larger than the view.
      let newFrameHeight = max(contentHeight, self.bounds.height)
      
      /// Set the text view's frame accordingly.
      textView.frame = NSRect(x: 0, y: 0, width: self.bounds.width, height: newFrameHeight)
      
      
    } else {
      /// In non-editable mode, simply match the bounds.
      textView.frame = self.bounds
      /// Invalidate intrinsic content size to trigger a height update.
      
    }
    
    textView.invalidateIntrinsicContentSize()
    let newHeight = textView.intrinsicContentSize.height
    /// Only notify if the height has changed significantly.
    if abs(newHeight - lastReportedHeight) > 1.0 {
      lastReportedHeight = newHeight
      heightChanged?(newHeight)
    }
    
    
  }
}


extension NSTextView {
  private var maximumUsableWidth: CGFloat {
    guard let scrollView = enclosingScrollView else {
      return bounds.width
    }

    let usableWidth = scrollView.contentSize.width - textContainerInset.width

    guard scrollView.rulersVisible, let rulerView = scrollView.verticalRulerView else {
      return usableWidth
    }

    return usableWidth - rulerView.requiredThickness
  }


  public var wrapsTextToHorizontalBounds: Bool {
    get {
      textContainer?.widthTracksTextView ?? false
    }
    set {
      textContainer?.widthTracksTextView = newValue

      let max = CGFloat.greatestFiniteMagnitude

      textContainer?.size = NSSize(width: max, height: max)

      if newValue {
        let newSize = NSSize(width: maximumUsableWidth, height: frame.height)

        self.frame = NSRect(origin: frame.origin, size: newSize)
      }
    }
  }
}
