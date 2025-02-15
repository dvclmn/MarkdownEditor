//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 10/2/2025.
//

import AppKit

import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift
import SwiftTreeSitter
import Neon

public class MarkdownController: NSViewController {

  let textView: MarkdownTextView
  let scrollView: NSScrollView
  
  private let highlighter: TextViewHighlighter?

  public init(configuration: EditorConfiguration) {
    
    /// Create text storage and layout manager
    let textStorage = NSTextStorage()
    let layoutManager = MarkdownLayoutManager(configuration: configuration)
    textStorage.addLayoutManager(layoutManager)

    /// Create text container
    let textContainer = NSTextContainer()
    textContainer.widthTracksTextView = true
    layoutManager.addTextContainer(textContainer)
    
    /// Create text view
    textView = MarkdownTextView(
      frame: .zero,
      textContainer: textContainer,
      configuration: configuration
    )
    
    scrollView = NSScrollView()
    scrollView.hasVerticalScroller = textView.configuration.isEditable
    scrollView.drawsBackground = false
    scrollView.documentView = textView
    
    do {
      self.highlighter = try Self.makeHighlighter(for: textView)
      
      super.init(nibName: nil, bundle: nil)
    } catch {
      print("Error creating highlighter: \(error)")
      self.highlighter = nil
      fatalError("Why didn't Neon start up? \(error)")
//      super.init(nibName: nil, bundle: nil)
    }
    
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func loadView() {
    /// Create scroll view
    
//    let scrollView = NSScrollView()
    
    

    self.view = scrollView
    
    /// Ensure that our subviews use autoresizing – or set up Auto Layout constraints here.
//    scrollView.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
//      scrollView.topAnchor.constraint(equalTo: topAnchor),
//      scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
//    ])
    

    highlighter?.observeEnclosingScrollView()


  }

  /// Override layout so that when the view's bounds change, we invalidate and recalc the intrinsic size.
//  public override func layout() {
//    super.layout()
//
//    /// Ensure the scroll view and text view have their frames updated.
//    scrollView.frame = self.bounds
//
//
//  }
}


//extension NSTextView {
//  private var maximumUsableWidth: CGFloat {
//    guard let scrollView = enclosingScrollView else {
//      return bounds.width
//    }
//
//    let usableWidth = scrollView.contentSize.width - textContainerInset.width
//
//    guard scrollView.rulersVisible, let rulerView = scrollView.verticalRulerView else {
//      return usableWidth
//    }
//
//    return usableWidth - rulerView.requiredThickness
//  }
//
//
//  public var wrapsTextToHorizontalBounds: Bool {
//    get {
//      textContainer?.widthTracksTextView ?? false
//    }
//    set {
//      textContainer?.widthTracksTextView = newValue
//
//      let max = CGFloat.greatestFiniteMagnitude
//
//      textContainer?.size = NSSize(width: max, height: max)
//
//      if newValue {
//        let newSize = NSSize(width: maximumUsableWidth, height: frame.height)
//
//        self.frame = NSRect(origin: frame.origin, size: newSize)
//      }
//    }
//  }
//}
