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
  
  var textView: MarkdownTextView
  @MainActor private let highlighter: TextViewHighlighter
  
  
  
  init(
    
    configuration: MarkdownEditorConfiguration
  ) {
    
    self.textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,

      configuration: configuration
    )
    
    let scrollView = NSScrollView()
    
    scrollView.hasVerticalScroller = true
    scrollView.documentView = textView
    
    do {
      self.highlighter = try Self.makeHighlighter(for: textView)
//      print("`TextViewHighlighter` is running.")
      super.init(nibName: nil, bundle: nil)
    } catch {
      fatalError("Error setting up the highlighter: \(error)")
    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private static func makeHighlighter(for textView: MarkdownTextView) throws -> TextViewHighlighter {
    
    textView.typingAttributes = textView.configuration.defaultTypingAttributes
    
    let markdownConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    let markdownInlineConfig = try LanguageConfiguration(
      tree_sitter_markdown_inline(),
      name: "Markdown Inline"
    )
    
    let provider: TokenAttributeProvider = { token in
      
//      print("`TokenAttributeProvider` called. Token: \(token)")

      return switch token.name {
         
        case let keyword where keyword.hasPrefix("punctuation"): [.foregroundColor: NSColor.red]
          
          //
          //        case let keyword where keyword.hasPrefix("*"): [.foregroundColor: NSColor.red]
          //        case "comment", "spell": [.foregroundColor: NSColor.green]
          //          // Note: Default is not actually applied to unstyled/untokenized text.
        default: [.foregroundColor: NSColor.blue]
      }
    }
    
    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: markdownConfig,
      attributeProvider: provider,
      languageProvider: { name in
        
        
        
        print("embedded language: ", name)
        
        switch name {
          case "markdown_inline":
//            print("Let's fire up markdown inline")
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
  
  
}
