//
//  ViewController.swift
//  MarkdownEditor
//
//  Created by Dave Coleman on 6/9/2024.
//

import AppKit

import Neon
import TreeSitterMarkdown
import TreeSitterMarkdownInline
import SwiftTreeSitter

import TreeSitterClient


public class MarkdownViewController: NSViewController {
  
  var textView: MarkdownTextView
//  @MainActor private let highlighter: TextViewHighlighter
  
  var scrollView: NSScrollView
  
  
  init(
    configuration: MarkdownEditorConfiguration
  ) {
    
    self.textView = MarkdownTextView(
      frame: .zero,
      textContainer: nil,
      configuration: configuration
    )
    
    self.scrollView = NSScrollView()
    
//    do {
//      self.highlighter = try Self.makeHighlighter(for: textView)
//      print("`TextViewHighlighter` is running.")
      super.init(nibName: nil, bundle: nil)
//    } catch {
//      fatalError("Error setting up the highlighter: \(error)")
//    }
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  private static func makeHighlighter(for textView: MarkdownTextView) throws -> TextViewHighlighter {
//    
//    textView.typingAttributes = textView.configuration.defaultTypingAttributes
//    
//    let markdownConfig = try LanguageConfiguration(
//      tree_sitter_markdown(),
//      name: "Markdown"
//    )
//    let markdownInlineConfig = try LanguageConfiguration(
//      tree_sitter_markdown_inline(),
//      name: "Markdown Inline"
//    )
//    
//    let provider: TokenAttributeProvider = { token in
//      
////      print("`TokenAttributeProvider` called. Token: \(token)")
//
//      return switch token.name {
//         
//        case let keyword where keyword.hasPrefix("punctuation"): [.foregroundColor: NSColor.red]
//          
//          //
//          //        case let keyword where keyword.hasPrefix("*"): [.foregroundColor: NSColor.red]
//          //        case "comment", "spell": [.foregroundColor: NSColor.green]
//          //          // Note: Default is not actually applied to unstyled/untokenized text.
//        default: [.foregroundColor: NSColor.blue]
//      }
//    }
//    
//    let highlighterConfig = TextViewHighlighter.Configuration(
//      languageConfiguration: markdownConfig,
//      attributeProvider: provider,
//      languageProvider: { name in
//        
//        
//        
//        print("embedded language: ", name)
//        
//        switch name {
//          case "markdown_inline":
////            print("Let's fire up markdown inline")
//            return markdownInlineConfig
//          default:
//            return nil
//        }
//      },
//      locationTransformer: { _ in nil }
//    )
//    
//    return try TextViewHighlighter(textView: textView, configuration: highlighterConfig)
//
//    
//  }
  
  public override func loadView() {

    do {
      try self.neonSetup()
    } catch {
      print("Error with Neon: \(error)")
    }
    
    setUpScrollView()

    self.view = textView.scrollView
    
    assert(self.textView.enclosingScrollView != nil, "I need the textView to have a scrollview.")
    
  }
  
  func neonSetup() throws {
    
    let languageConfig = try LanguageConfiguration(
      tree_sitter_markdown(),
      name: "Markdown"
    )
    
    let clientConfig = TreeSitterClient.Configuration(
      languageProvider: { identifier in
        print("Nested languages? \(identifier)")
        return nil
      },
      contentProvider: { [textView] length in
        
        print("Understanding content provider:\n`[textView]`: \(textView.description)")
        print("`length`: \(length.description)")
        
        return .init(string: textView.string)
      },
      lengthProvider: { [textView] in
        textView.string.utf16.count
        
      },
      invalidationHandler: { set in
        print("Invalidations: \(set)")
      },
      locationTransformer: { location in
        // optionally, use the UTF-16 location to produce a line-relative Point structure.
        return nil
      }
    )
    
    let client = try TreeSitterClient(
      rootLanguageConfig: languageConfig,
      configuration: clientConfig
    )
    
    let source = textView.string
    
    let provider = source.predicateTextProvider
    
    Task { @MainActor in
      let highlights = try await client.highlights(in: NSRange(location: 2, length: 20), provider: provider)

      print("Highlights: ", highlights)
    }

    
  }
  
  
}
