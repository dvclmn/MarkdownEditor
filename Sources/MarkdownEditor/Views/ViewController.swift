//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import SwiftTreeSitter
import Neon

public class MarkdownViewController: NSViewController {
  
//  var scrollView: MarkdownScrollView
  var textView: MarkdownTextView
  
  private let highlighter: TextViewHighlighter
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {

//    self.scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    
    self.textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: configuration)
    
    let scrollView = NSScrollView()
    
    scrollView.hasVerticalScroller = true
    scrollView.documentView = textView
    
    self.highlighter = try! Self.makeHighlighter(for: textView)
    
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  private static func makeHighlighter(for textView: MarkdownTextView) throws -> TextViewHighlighter {
    
    // Set the default styles. This is applied by stock `NSTextStorage`s during
    // so-called "attribute fixing" when you type, and we emulate that as
    // part of the highlighting process in `TextViewSystemInterface`.
    textView.typingAttributes = [
      .foregroundColor: NSColor.gray,
      .font: NSFont.systemFont(ofSize: textView.configuration.fontSize),
    ]
    
    let provider: TokenAttributeProvider = { token in
      return switch token.name {
        case let keyword where keyword.hasPrefix("keyword"): [.foregroundColor: NSColor.red]
        case "comment", "spell": [.foregroundColor: NSColor.green]
          // Note: Default is not actually applied to unstyled/untokenized text.
        default: [.foregroundColor: NSColor.blue]
      }
    }
    
    // this is doing both synchronous language initialization everything, but TreeSitterClient supports lazy loading for embedded languages
    let markdownConfig = try! LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    
    let markdownInlineConfig = try! LanguageConfiguration(
      tree_sitter_markdown_inline(),
      name: "MarkdownInline",
      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
    )
    
    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: markdownConfig,
      attributeProvider: provider,
      languageProvider: { name in
        print("embedded language: ", name)
        
        switch name {
          case "markdown_inline":
            return markdownInlineConfig
          default:
            return nil
        }
      },
      locationTransformer: { _ in nil }
    )
    
    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
  }
  
  public override func loadView() {

   
    
    let max = CGFloat.greatestFiniteMagnitude
    
    textView.minSize = NSSize.zero
    textView.maxSize = NSSize(width: max, height: max)
    textView.isVerticallyResizable = true
    textView.isHorizontallyResizable = true
    
    textView.isRichText = false  // Discards any attributes when pasting.
    
    self.view = textView.scrollView
    
    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")
    
    // this has to be done after the textview has been embedded in the scrollView if
    // it wasn't that way on creation
    highlighter.observeEnclosingScrollView()
    
  }

  
  
//  public override func loadView() {
//    
//    let max = CGFloat.greatestFiniteMagnitude
//    
//    textView.minSize = NSSize.zero
//    textView.maxSize = NSSize(width: max, height: max)
//    textView.isVerticallyResizable = true
//    textView.isHorizontallyResizable = true
//    
//    self.view = scrollView
//    
//    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")
//
//  }
//  
}
