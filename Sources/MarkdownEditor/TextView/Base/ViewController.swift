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

@MainActor
public class MarkdownController: NSViewController {

  let textView: NSTextView
  private let highlighter: TextViewHighlighter
  
  var currentTokens: [Token] = []
//  let tokenDebugView: NSTextField
  

  public init(configuration: EditorConfiguration) {
    
    textView = NSTextView(usingTextLayoutManager: false)
    
//    tokenDebugView = NSTextField(labelWithString: "")
//    tokenDebugView.maximumNumberOfLines = 0
//    tokenDebugView.lineBreakMode = .byWordWrapping
//    
    do {
      self.highlighter = try Self.makeHighlighter(
        for: textView,
        with: configuration
      )
      super.init(nibName: nil, bundle: nil)
      
      if textView.textLayoutManager == nil {
        textView.layoutManager?.allowsNonContiguousLayout = true
      }
      
//      setupTokenTracking()
      
    } catch {
      fatalError("Error starting `TextViewHighlighter`: \(error)")
    }
    
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  private func setupTokenTracking() {
//    NotificationCenter.default.addObserver(
//      self,
//      selector: #selector(selectionDidChange(_:)),
//      name: NSTextView.didChangeSelectionNotification,
//      object: textView
//    )
//  }
  
  @objc private func selectionDidChange(_ notification: Notification) {
    guard let selectedRange = textView.selectedRanges.first?.rangeValue,
          selectedRange.length == 0 else {
      
      // Clear debug view if there's a selection
//      tokenDebugView.stringValue = ""
      return
    }
    
    let position = selectedRange.location
    let matchingTokens = currentTokens.filter { token in
      NSLocationInRange(position, token.range)
    }
    
    let resultingString = matchingTokens
      .map { "Token at position \(position): \($0.debugDescription)" }
      .joined(separator: "\n")
    
    print("Token: \(resultingString)")
  }
  
  public override func loadView() {
    
    let containerView = NSView()
    
    let scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    
    let max = CGFloat.greatestFiniteMagnitude
    textView.minSize = NSSize.zero
    textView.maxSize = NSSize(width: max, height: max)
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = true
    
    // Configure text container to match scroll view's width
    if let textContainer = textView.textContainer {
      textContainer.containerSize = NSSize(width: max, height: max)
      textContainer.widthTracksTextView = true
    }
    
    
    
    scrollView.documentView = textView
    
    // Setup debug view
//    tokenDebugView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    containerView.addSubview(scrollView)
//    containerView.addSubview(tokenDebugView)
    
//    NSLayoutConstraint.activate([
//      scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
//      scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//      scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//      scrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8),
//      
//      tokenDebugView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
//      tokenDebugView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//      tokenDebugView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//      tokenDebugView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//    ])
    
    self.view = scrollView

  }
  
  public override func viewDidAppear() {
    super.viewDidAppear()
    // Move the highlighter observation here
    highlighter.observeEnclosingScrollView()
  }
  
  public override func viewWillLayout() {
    super.viewWillLayout()
    // Ensure proper sizing
    if let scrollView = view as? NSScrollView {
      textView.frame = scrollView.contentView.bounds
    }
  }

}



//@MainActor
//final class TextViewController: NSUIViewController {
//  private let textView: NSUITextView
//  private let highlighter: TextViewHighlighter
//  
//  init() {
//    self.textView = NSUITextView(usingTextLayoutManager: false)
//    
//    self.highlighter = try! Self.makeHighlighter(for: textView)
//    
//    super.init(nibName: nil, bundle: nil)
//    
//    // enable non-continguous layout for TextKit 1
//    if textView.textLayoutManager == nil {
//      textView.nsuiLayoutManager?.allowsNonContiguousLayout = true
//    }
//  }
//  
//  @available(*, unavailable)
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  private static func makeHighlighter(for textView: NSUITextView) throws -> TextViewHighlighter {
//    let regularFont = NSUIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
//    let boldFont = NSUIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
//    let italicDescriptor = regularFont.fontDescriptor.nsuiWithSymbolicTraits(.traitItalic) ?? regularFont.fontDescriptor
//    
//    let italicFont = NSUIFont(nsuiDescriptor: italicDescriptor, size: 16) ?? regularFont
//    
//    // Set the default styles. This is applied by stock `NSTextStorage`s during
//    // so-called "attribute fixing" when you type, and we emulate that as
//    // part of the highlighting process in `TextViewSystemInterface`.
//    textView.typingAttributes = [
//      .foregroundColor: NSUIColor.darkGray,
//      .font: regularFont,
//    ]
//    
//    let provider: TokenAttributeProvider = { token in
//      return switch token.name {
//        case let keyword where keyword.hasPrefix("keyword"): [.foregroundColor: NSUIColor.red, .font: boldFont]
//        case "comment", "spell": [.foregroundColor: NSUIColor.green, .font: italicFont]
//          // Note: Default is not actually applied to unstyled/untokenized text.
//        default: [.foregroundColor: NSUIColor.blue, .font: regularFont]
//      }
//    }
//    
//    // this is doing both synchronous language initialization everything, but TreeSitterClient supports lazy loading for embedded languages
//    let markdownConfig = try! LanguageConfiguration(
//      tree_sitter_markdown(),
//      name: "Markdown"
//    )
//    
//    let markdownInlineConfig = try! LanguageConfiguration(
//      tree_sitter_markdown_inline(),
//      name: "MarkdownInline",
//      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
//    )
//    
//    let swiftConfig = try! LanguageConfiguration(
//      tree_sitter_swift(),
//      name: "Swift"
//    )
//    
//    let highlighterConfig = TextViewHighlighter.Configuration(
//      languageConfiguration: swiftConfig, // the root language
//      attributeProvider: provider,
//      languageProvider: { name in
//        print("embedded language: ", name)
//        
//        switch name {
//          case "swift":
//            return swiftConfig
//          case "markdown_inline":
//            return markdownInlineConfig
//          default:
//            return nil
//        }
//      },
//      locationTransformer: { _ in nil }
//    )
//    
//    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
//  }
//  
//  override func loadView() {
//#if canImport(AppKit) && !targetEnvironment(macCatalyst)
//    let scrollView = NSScrollView()
//    
//    scrollView.hasVerticalScroller = true
//    scrollView.documentView = textView
//    
//    let max = CGFloat.greatestFiniteMagnitude
//    
//    textView.minSize = NSSize.zero
//    textView.maxSize = NSSize(width: max, height: max)
//    textView.isVerticallyResizable = true
//    textView.isHorizontallyResizable = true
//    
//    textView.isRichText = false  // Discards any attributes when pasting.
//    
//    self.view = scrollView
//#else
//    self.view = textView
//#endif
//    
//    // this has to be done after the textview has been embedded in the scrollView if
//    // it wasn't that way on creation
//    highlighter.observeEnclosingScrollView()
//    
//    regularTestWithSwiftCode()
//  }
//  
//  func regularTestWithSwiftCode() {
//    let url = Bundle.main.url(forResource: "test", withExtension: "code")!
//    let content = try! String(contentsOf: url)
//    
//    textView.text = content
//  }
//  
//  func doBigMarkdownTest() {
//    let url = Bundle.main.url(forResource: "big_test", withExtension: "md")!
//    let content = try! String(contentsOf: url)
//    
//    textView.text = content
//    
//    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//      let range = NSRange(location: content.utf16.count, length: 0)
//      
//      self.textView.scrollRangeToVisible(range)
//    }
//  }
//}
