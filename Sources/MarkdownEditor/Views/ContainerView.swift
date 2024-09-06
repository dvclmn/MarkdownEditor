//
//  MainView.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 17/8/2024.
//

import AppKit
import Neon
import NSUI
import SwiftTreeSitter
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import TreeSitterSwift

public class MarkdownContainerView: NSView {
  
  let highlighter: TextViewHighlighter?
  
  var textView: MarkdownTextView
  let scrollView: MarkdownScrollView
  
  init(frame: NSRect, configuration: MarkdownEditorConfiguration) {
    
    let textView = MarkdownTextView(frame: .zero, textContainer: nil, configuration: configuration)
    self.textView = textView
    
    let scrollView = MarkdownScrollView(frame: .zero, configuration: configuration)
    self.scrollView = scrollView
    
    do {
      self.highlighter = try Self.makeHighlighter(for: textView)
      super.init(frame: frame)
      setupViews()
    } catch {
      
      self.highlighter = nil
      
      super.init(frame: frame)
      print("Issue with highlighter")
    }
    
    
  }

  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private static func makeHighlighter(for textView: MarkdownTextView) throws -> TextViewHighlighter {
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
    
    let markdownConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    
    let markdownInlineConfig = try LanguageConfiguration(
      tree_sitter_markdown_inline(),
      name: "MarkdownInline",
      bundleName: "TreeSitterMarkdown_TreeSitterMarkdownInline"
    )
    
    let swiftConfig = try LanguageConfiguration(
      tree_sitter_swift(),
      name: "Swift"
    )
    

    let highlighterConfig = TextViewHighlighter.Configuration(
      languageConfiguration: swiftConfig, // the root language
      attributeProvider: provider,
      languageProvider: { name in
        print("embedded language: ", name)
        
        switch name {
          case "swift":
            return swiftConfig
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
  
  private func setupViews() {

    addSubview(scrollView)
    
    scrollView.hasVerticalScroller = true
    scrollView.hasHorizontalScroller = false
    scrollView.autohidesScrollers = true
    
    scrollView.documentView = textView
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false

    scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    
    scrollView.drawsBackground = false
    
    if let highlighter = self.highlighter {
      highlighter.observeEnclosingScrollView()
    } else {
      print("There is no highlighter available")
    }
    
  }
  

}
