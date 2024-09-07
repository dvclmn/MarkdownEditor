//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit
import Neon
import NSUI
import SwiftTreeSitter
import TreeSitterMarkdown
import TreeSitterMarkdownInline

public class MarkdownViewController: NSViewController {
  
  var scrollView: MarkdownScrollView
  var textView: MarkdownTextView
  
  let highlighter: TextViewHighlighter
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {

    self.scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    self.textView = self.scrollView.documentView as! MarkdownTextView
    self.highlighter = try! Self.makeHighlighter(for: textView)
    
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  private static func makeHighlighter(for textView: NSUITextView) throws -> TextViewHighlighter {
    let regularFont = NSUIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
    let boldFont = NSUIFont.monospacedSystemFont(ofSize: 16, weight: .bold)
    let italicDescriptor = regularFont.fontDescriptor.nsuiWithSymbolicTraits(.traitItalic) ?? regularFont.fontDescriptor
    
    let italicFont = NSUIFont(nsuiDescriptor: italicDescriptor, size: 16) ?? regularFont
    
    // Set the default styles. This is applied by stock `NSTextStorage`s during
    // so-called "attribute fixing" when you type, and we emulate that as
    // part of the highlighting process in `TextViewSystemInterface`.
    textView.typingAttributes = [
      .foregroundColor: NSUIColor.darkGray,
      .font: regularFont,
    ]
    
    let provider: TokenAttributeProvider = { token in
      return switch token.name {
        case let keyword where keyword.hasPrefix("keyword"): [.foregroundColor: NSUIColor.red, .font: boldFont]
        case "comment", "spell": [.foregroundColor: NSUIColor.green, .font: italicFont]
          // Note: Default is not actually applied to unstyled/untokenized text.
        default: [.foregroundColor: NSUIColor.blue, .font: regularFont]
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
      languageConfiguration: markdownConfig, // the root language
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
    
    self.view = scrollView
    
    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")

  }
  
}
