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

  /// Expose text view for additional configuration if needed
  //  public func getTextView() -> MarkdownTextView {
  //    return textView
  //  }

//  /// Make sure that when our bounds change (e.g. a SwiftUI width change), we force the text view to lay out again.
//  public override func layout() {
//    super.layout()
//    print("Performed layout at \(Date())")
//
//
//    /// Only needed for non‑editable mode:
//    if !textView.isEditable {
//      /// Given that the intrinsic height depends on the width,
//      /// force a recomputation:
//      textView.invalidateIntrinsicContentSize()
//      /// Optionally (or via a delegate) call back with the new height:
//      let newHeight = textView.intrinsicContentSize.height
//      /// You might then call a closure stored on MarkdownScrollView,
//      /// or set some property that your NSViewRepresentable observes.
//    }
//
//
//    //    let newFrame = self.bounds
//    //    textView.frame = newFrame
//  }
  
  
  // Override layout so that when the view's bounds change, we invalidate and recalc the intrinsic size.
  public override func layout() {
    super.layout()
    
    // Ensure the scroll view and text view have their frames updated.
    scrollView.frame = self.bounds
    textView.frame = self.bounds
    
    // In non-editable mode we want the text view to report its new natural height.
    if !textView.isEditable {
      // Force a re-layout so that the intrinsicContentSize is recalculated.
      textView.invalidateIntrinsicContentSize()
      let newHeight = textView.intrinsicContentSize.height
      
      // Only notify if the height has changed significantly.
      if abs(newHeight - lastReportedHeight) > 1.0 {
        lastReportedHeight = newHeight
        heightChanged?(newHeight)
      }
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
